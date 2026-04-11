extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -600.0
const GRAVITY = 980.0
const PICKAXE_RANGE = 60.0
const PICKAXE_DAMAGE = 1

var can_swing: bool = true
var facing_right: bool = true
var can_break: bool = true
var is_dead: bool = false

@onready var axe: Sprite2D = $Axe
@onready var body_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fuse_sprite: AnimatedSprite2D = $FuseSprite
@onready var swing_sound: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var strike_sound: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var lightning_sound: AudioStreamPlayer = AudioStreamPlayer.new()

var shards_collected: int:
	get: return GameState.shards_collected
	set(v): GameState.shards_collected = v

var health: int:
	get: return GameState.health
	set(v): GameState.health = v

var lives: int:
	get: return GameState.lives
	set(v): GameState.lives = v

func _ready() -> void:
	swing_sound.stream = load("res://echoveil/music/animations/axe swing.mp3")
	swing_sound.volume_db = -15.0
	add_child(swing_sound)

	strike_sound.stream = load("res://echoveil/music/animations/axe strike.mp3")
	strike_sound.volume_db = -10.0
	add_child(strike_sound)

	lightning_sound.stream = load("res://echoveil/music/animations/axe strike.mp3")
	lightning_sound.volume_db = -5.0
	add_child(lightning_sound)

	body_sprite.play(&"idle")
	fuse_sprite.play(&"idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# DEATH CHECK
	if GameState.health <= 0:
		_die()
		return

	# GRAVITY
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# LEFT / RIGHT
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		facing_right = direction > 0
		body_sprite.flip_h = not facing_right
		fuse_sprite.flip_h = not facing_right
		axe.scale.x = 0.08 if facing_right else -0.08
		axe.position.x = 60 if facing_right else -60
		fuse_sprite.position.x = 40 if facing_right else -40
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)

	# Animation state (don't override swing)
	if can_swing:
		var target = &"run" if direction else &"idle"
		if body_sprite.animation != target:
			body_sprite.play(target)

	# PICKAXE SWING
	if Input.is_action_just_pressed("swing") and can_swing:
		swing_pickaxe()

	# BREAK / LIGHTNING STRIKE
	if Input.is_action_just_pressed("break_power") and GameState.lives >= 3 and can_break:
		_lightning_strike()

	move_and_slide()

func _die() -> void:
	is_dead = true
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Fuse panics
	fuse_sprite.play(&"panic")
	body_sprite.play(&"idle")

	# Red screen flash
	var flash_layer = CanvasLayer.new()
	flash_layer.layer = 30
	get_parent().add_child(flash_layer)

	var flash = ColorRect.new()
	flash.color = Color(1, 0, 0, 0.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_layer.add_child(flash)

	var tween = create_tween()
	tween.tween_property(flash, "color", Color(1, 0, 0, 0.65), 0.3)
	tween.tween_property(flash, "color", Color(1, 0, 0, 0.45), 1.0)

	# Reset for respawn (keep shards)
	GameState.health = 3
	GameState.lives = 0

	var scene_path = get_tree().current_scene.scene_file_path
	await get_tree().create_timer(1.8).timeout
	get_tree().call_deferred("change_scene_to_file", scene_path)

func swing_pickaxe() -> void:
	can_swing = false

	var swing_dir = 1.0 if facing_right else -1.0

	swing_sound.play()
	body_sprite.play(&"swing")
	fuse_sprite.play(&"react")

	# Animate the axe: chop forward then return
	var chop_rotation = 1.4 * swing_dir
	var tween = create_tween()
	tween.tween_property(axe, "rotation", chop_rotation, 0.12)
	tween.tween_property(axe, "rotation", 0.0, 0.18)

	var hit_pos = global_position + Vector2(PICKAXE_RANGE * swing_dir, 227)

	# Check for rocks in range
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = hit_pos
	query.collision_mask = 2
	query.collide_with_areas = true
	var results = space.intersect_point(query)

	if results.size() > 0:
		strike_sound.play()

	for result in results:
		var body = result.collider
		if body.has_method("take_damage"):
			body.take_damage(PICKAXE_DAMAGE)

	# Cooldown then restore idle/run
	await get_tree().create_timer(0.3).timeout
	can_swing = true
	fuse_sprite.play(&"idle")
	var resume = &"run" if abs(velocity.x) > 10 else &"idle"
	body_sprite.play(resume)

func _lightning_strike() -> void:
	can_break = false
	GameState.lives = 0

	lightning_sound.play()
	fuse_sprite.play(&"react")

	# Lightning image + screen flash overlay
	var flash_layer = CanvasLayer.new()
	flash_layer.layer = 30
	get_parent().add_child(flash_layer)

	var flash = ColorRect.new()
	flash.color = Color(0.9, 0.0, 1.0, 0.45)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_layer.add_child(flash)

	var bolt = Sprite2D.new()
	bolt.texture = load("res://echoveil/Animations/axe lightning.png")
	bolt.position = flash_layer.get_viewport().get_visible_rect().size * 0.5
	bolt.scale = Vector2(0.6, 0.6)
	bolt.modulate = Color(1.0, 0.5, 1.0, 1.0)
	flash_layer.add_child(bolt)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "color", Color(0.9, 0.0, 1.0, 0.0), 0.6)
	tween.tween_property(bolt, "modulate", Color(1.0, 0.5, 1.0, 0.0), 0.6)
	tween.chain().tween_callback(flash_layer.queue_free)

	# Stun all drones
	for drone in get_tree().get_nodes_in_group("drone"):
		if drone.has_method("stun"):
			drone.stun(4.0)

	await get_tree().create_timer(1.0).timeout
	fuse_sprite.play(&"idle")
	can_break = true
