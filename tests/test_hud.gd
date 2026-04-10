## Unit tests for hud.gd
## Requires: GdUnit4 addon (install via the Godot Asset Library or
##   https://github.com/MikeSchulze/gdUnit4 — add it as res://addons/gdUnit4/)
##
## Two scene-level bugs are documented and tested here:
##
##   BUG-1 (group name mismatch)
##     hud.gd calls get_first_node_in_group("player") with a lowercase 'p',
##     but gameclaude.tscn registers the Player node in group "Player" (capital P).
##     The HUD therefore never finds the player and the label is never updated.
##
##   BUG-2 (label node name mismatch)
##     hud.gd references $ShardLabel (camelCase), but the Label node in
##     gameclaude.tscn is named "shard label" (lowercase with a space).
##     This would crash at runtime the moment a player IS found — though BUG-1
##     currently prevents that code path from ever being reached.
extends GdUnitTestSuite

const HUD_SCRIPT := "res://hud.gd"

# Creates a CanvasLayer with hud.gd attached and one Label child.
# Pass label_name = "ShardLabel" for the correct setup, or the scene's actual
# name "shard label" to reproduce BUG-2.
func _make_hud(label_name: String) -> CanvasLayer:
	var hud := CanvasLayer.new()
	hud.set_script(load(HUD_SCRIPT))
	var label := Label.new()
	label.name = label_name
	hud.add_child(label)
	add_child(hud)
	return hud

# Creates a minimal player mock and adds it to the given group.
func _make_player(group_name: String, shards: int) -> Node2D:
	var script := GDScript.new()
	script.source_code = "extends Node2D\nvar shards_collected: int = 0\n"
	script.reload()
	var node := Node2D.new()
	node.set_script(script)
	node.name = "Player"
	node.shards_collected = shards
	node.add_to_group(group_name)
	add_child(node)
	return node

# ── intended behaviour ────────────────────────────────────────────────────────
# These tests construct the correct setup (right group name, right label name)
# to verify the HUD logic in isolation, independent of the scene-level bugs.

func test_label_shows_correct_shard_count() -> void:
	var _player := auto_free(_make_player("player", 7))  # lowercase — as hud.gd expects
	var hud    := auto_free(_make_hud("ShardLabel"))      # correct label name
	await get_tree().process_frame
	var label := hud.get_node("ShardLabel") as Label
	assert_str(label.text).is_equal("Shards: 7")

func test_label_updates_when_shard_count_changes() -> void:
	var player := auto_free(_make_player("player", 0))
	var hud    := auto_free(_make_hud("ShardLabel"))
	await get_tree().process_frame
	player.shards_collected = 3
	await get_tree().process_frame
	var label := hud.get_node("ShardLabel") as Label
	assert_str(label.text).is_equal("Shards: 3")

func test_no_crash_when_player_is_absent() -> void:
	# hud.gd has `if player:` so a missing player must not crash — the label
	# simply remains unchanged.
	var hud := auto_free(_make_hud("ShardLabel"))
	await get_tree().process_frame   # _process runs; player is null → skipped
	assert_bool(true).is_true()      # reaching here proves no crash

# ── BUG-1: group name mismatch ────────────────────────────────────────────────

func test_bug1_hud_never_updates_when_player_group_is_capitalised() -> void:
	# gameclaude.tscn uses group "Player" (capital P); hud.gd looks for "player".
	# With the scene as-is the label must never be updated.
	# Fix: change groups=["Player"] to groups=["player"] in gameclaude.tscn,
	# OR change hud.gd to call get_first_node_in_group("Player").
	var _player := auto_free(_make_player("Player", 99))  # capital P — as in scene
	var hud     := auto_free(_make_hud("ShardLabel"))
	await get_tree().process_frame
	var label := hud.get_node("ShardLabel") as Label
	assert_str(label.text).is_not_equal("Shards: 99")

# ── BUG-2: label node name mismatch ──────────────────────────────────────────

func test_bug2_shardlabel_path_does_not_resolve_to_scene_label() -> void:
	# The label in gameclaude.tscn is named "shard label" (lowercase + space).
	# hud.gd uses $ShardLabel which resolves to a different node path.
	# When a player IS found (after BUG-1 is fixed), $ShardLabel returns null
	# and the assignment crashes.
	# Fix: rename the Label node in gameclaude.tscn to "ShardLabel".
	var hud := auto_free(_make_hud("shard label"))  # actual scene node name
	await get_tree().process_frame
	# The path hud.gd uses cannot find the label under its scene name:
	assert_object(hud.get_node_or_null("ShardLabel")).is_null()
	# But the actual scene node IS there under its real name:
	assert_object(hud.get_node_or_null("shard label")).is_not_null()
