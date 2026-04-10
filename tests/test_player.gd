## Unit tests for player.gd
## Requires: GdUnit4 addon (install via the Godot Asset Library or
##   https://github.com/MikeSchulze/gdUnit4 — add it as res://addons/gdUnit4/)
extends GdUnitTestSuite

const PLAYER_SCRIPT := "res://player.gd"

# Spawns a bare CharacterBody2D with the player script attached.
# A CollisionShape2D is added so physics queries don't error on a shapeless body.
func _make_player() -> CharacterBody2D:
	var p := CharacterBody2D.new()
	p.set_script(load(PLAYER_SCRIPT))
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	p.add_child(shape)
	add_child(p)
	return p

# ── initial state ─────────────────────────────────────────────────────────────

func test_initial_shards_collected_is_zero() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	assert_int(p.shards_collected).is_equal(0)

func test_initial_can_swing_is_true() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	assert_bool(p.can_swing).is_true()

func test_initial_facing_right_is_true() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	assert_bool(p.facing_right).is_true()

# ── constants (snapshot tests — catch accidental balance changes) ─────────────

func test_speed_constant() -> void:
	var p := auto_free(_make_player())
	assert_float(p.SPEED).is_equal(300.0)

func test_jump_force_constant() -> void:
	var p := auto_free(_make_player())
	assert_float(p.JUMP_FORCE).is_equal(-400.0)

func test_gravity_constant() -> void:
	var p := auto_free(_make_player())
	assert_float(p.GRAVITY).is_equal(980.0)

func test_pickaxe_range_constant() -> void:
	var p := auto_free(_make_player())
	assert_float(p.PICKAXE_RANGE).is_equal(60.0)

func test_pickaxe_damage_constant() -> void:
	var p := auto_free(_make_player())
	assert_int(p.PICKAXE_DAMAGE).is_equal(1)

# ── swing cooldown ────────────────────────────────────────────────────────────

func test_swing_immediately_disables_can_swing() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	p.swing_pickaxe()
	assert_bool(p.can_swing).is_false()

func test_calling_swing_while_on_cooldown_does_not_crash() -> void:
	# swing_pickaxe() is called directly here, bypassing the _physics_process
	# guard (if can_swing). Calling it twice must not throw or corrupt state.
	var p := auto_free(_make_player())
	await get_tree().process_frame
	p.swing_pickaxe()
	p.swing_pickaxe()
	assert_bool(p.can_swing).is_false()

func test_can_swing_restored_after_cooldown() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	p.swing_pickaxe()
	assert_bool(p.can_swing).is_false()
	await get_tree().create_timer(0.4).timeout   # cooldown is 0.3 s
	assert_bool(p.can_swing).is_true()

# ── facing direction ──────────────────────────────────────────────────────────

func test_swing_does_not_crash_when_facing_right() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	p.facing_right = true
	p.swing_pickaxe()
	assert_bool(p.can_swing).is_false()

func test_swing_does_not_crash_when_facing_left() -> void:
	var p := auto_free(_make_player())
	await get_tree().process_frame
	p.facing_right = false
	p.swing_pickaxe()
	assert_bool(p.can_swing).is_false()

# Integration note: verifying that rocks at the correct hit position take damage
# (i.e. the PICKAXE_RANGE * direction offset is applied properly) requires a
# full scene with physics layers configured. That scenario belongs in an
# integration test against gameclaude.tscn.
