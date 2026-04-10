## Unit tests for shard.gd
## Requires: GdUnit4 addon (install via the Godot Asset Library or
##   https://github.com/MikeSchulze/gdUnit4 — add it as res://addons/gdUnit4/)
extends GdUnitTestSuite

const SHARD_SCENE := "res://shard.tscn"

# Returns a Node2D with `shards_collected` but no `collect_shard()` method,
# mimicking the fallback path in shard._on_body_entered.
func _make_player_without_collect_shard(initial_shards: int = 0) -> Node2D:
	var script := GDScript.new()
	script.source_code = "extends Node2D\nvar shards_collected: int = 0\n"
	script.reload()
	var node := Node2D.new()
	node.set_script(script)
	node.name = "Player"
	node.shards_collected = initial_shards
	add_child(node)
	return node

# Returns a Node2D that has a `collect_shard()` method, exercising the primary
# collection path.
func _make_player_with_collect_shard() -> Node2D:
	var script := GDScript.new()
	script.source_code = (
		"extends Node2D\n"
		"var shards_collected: int = 0\n"
		"var collect_called: bool = false\n"
		"func collect_shard() -> void:\n"
		"\tshards_collected += 1\n"
		"\tcollect_called = true\n"
	)
	script.reload()
	var node := Node2D.new()
	node.set_script(script)
	node.name = "Player"
	add_child(node)
	return node

# ── initialisation ────────────────────────────────────────────────────────────

func test_start_y_matches_initial_position_y() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	shard.position = Vector2(0.0, 100.0)
	add_child(shard)
	await get_tree().process_frame
	assert_float(shard.start_y).is_equal(100.0)

func test_bob_offset_is_within_zero_to_tau_on_ready() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	assert_float(shard.bob_offset).is_between(0.0, TAU)

# ── bobbing animation ─────────────────────────────────────────────────────────

func test_bob_offset_advances_each_frame() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var offset_before := shard.bob_offset
	await get_tree().process_frame
	assert_float(shard.bob_offset).is_greater(offset_before)

func test_bob_y_displacement_stays_within_four_pixel_amplitude() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	shard.position = Vector2(0.0, 50.0)
	add_child(shard)
	for _i in range(30):
		await get_tree().process_frame
		var delta_y := shard.position.y - shard.start_y
		assert_float(delta_y).is_between(-4.01, 4.01)

# ── collection — primary path (collect_shard method exists) ───────────────────

func test_collection_calls_collect_shard_when_method_exists() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var player := auto_free(_make_player_with_collect_shard())
	shard._on_body_entered(player)
	assert_bool(player.collect_called).is_true()

func test_collection_increments_shards_collected_via_collect_shard() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var player := auto_free(_make_player_with_collect_shard())
	shard._on_body_entered(player)
	assert_int(player.shards_collected).is_equal(1)

# ── collection — fallback path (no collect_shard method) ─────────────────────

func test_collection_increments_shards_collected_directly_when_no_method() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var player := auto_free(_make_player_without_collect_shard(5))
	shard._on_body_entered(player)
	assert_int(player.shards_collected).is_equal(6)

# ── post-collection state ─────────────────────────────────────────────────────

func test_shard_is_freed_after_player_collects_it() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var player := auto_free(_make_player_without_collect_shard())
	shard._on_body_entered(player)
	await get_tree().process_frame
	assert_bool(is_instance_valid(shard)).is_false()

# ── non-player bodies ─────────────────────────────────────────────────────────

func test_non_player_body_does_not_collect_shard() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var other := auto_free(Node2D.new())
	other.name = "NotAPlayer"
	shard._on_body_entered(other)
	await get_tree().process_frame
	assert_bool(is_instance_valid(shard)).is_true()

# BUG: collection is gated on body.name == "Player" (exact string match).
# Renaming the player node in the scene would silently break shard collection.
# Consider using a group check or a duck-type check instead.
func test_body_named_differently_is_not_collected() -> void:
	var shard := auto_free(load(SHARD_SCENE).instantiate())
	add_child(shard)
	await get_tree().process_frame
	var player := auto_free(_make_player_without_collect_shard(0))
	player.name = "player"   # lowercase — does not match "Player"
	shard._on_body_entered(player)
	# shard should survive; player count must be unchanged
	await get_tree().process_frame
	assert_bool(is_instance_valid(shard)).is_true()
	assert_int(player.shards_collected).is_equal(0)
