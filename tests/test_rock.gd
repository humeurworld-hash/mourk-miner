## Unit tests for rock.gd
## Requires: GdUnit4 addon (install via the Godot Asset Library or
##   https://github.com/MikeSchulze/gdUnit4 — add it as res://addons/gdUnit4/)
extends GdUnitTestSuite

const ROCK_SCENE := "res://rock.tscn"

# ── health ───────────────────────────────────────────────────────────────────

func test_initial_health_is_two() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	assert_int(rock.health).is_equal(2)

func test_single_hit_reduces_health_to_one() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(1)
	assert_int(rock.health).is_equal(1)

func test_single_hit_does_not_destroy_rock() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(1)
	await get_tree().process_frame
	assert_bool(is_instance_valid(rock)).is_true()

func test_two_sequential_hits_destroy_rock() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(1)
	rock.take_damage(1)
	await get_tree().process_frame
	assert_bool(is_instance_valid(rock)).is_false()

func test_lethal_single_hit_destroys_rock() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(2)
	await get_tree().process_frame
	assert_bool(is_instance_valid(rock)).is_false()

func test_excess_damage_destroys_rock() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(99)
	await get_tree().process_frame
	assert_bool(is_instance_valid(rock)).is_false()

func test_zero_damage_leaves_rock_alive_with_full_health() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(0)
	assert_int(rock.health).is_equal(2)
	assert_bool(is_instance_valid(rock)).is_true()

# BUG: rock.gd subtracts damage without guarding against negative values, so
# take_damage(-1) increases health to 3 instead of being rejected.
# This test documents the current broken behaviour; update the assertion to
# .is_equal(2) once the guard (`if amount <= 0: return`) is added.
func test_negative_damage_currently_increases_health() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	rock.take_damage(-1)
	assert_int(rock.health).is_equal(3)

# ── shard spawning ───────────────────────────────────────────────────────────

func test_shard_scene_is_loaded_on_ready() -> void:
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame
	assert_object(rock.shard_scene).is_not_null()

func test_destroying_rock_spawns_two_shards() -> void:
	# spawn_shards() calls get_tree().current_scene.add_child(shard).
	# In GdUnit4 the current scene is the test runner, so we count how many
	# children are added to it during the destruction frame.
	var rock := auto_free(load(ROCK_SCENE).instantiate())
	add_child(rock)
	await get_tree().process_frame

	var scene_root := get_tree().current_scene
	var before := scene_root.get_child_count()

	rock.take_damage(2)
	await get_tree().process_frame

	# The rock is a child of this test suite (not scene_root), so the only
	# additions to scene_root are the two spawned shards.
	assert_int(scene_root.get_child_count() - before).is_equal(2)
