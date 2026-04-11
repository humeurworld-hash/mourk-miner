extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -600.0
const GRAVITY = 980.0
const PICKAXE_RANGE = 60.0
const PICKAXE_DAMAGE = 1

var can_swing: bool = true
var facing_right: bool = true

@onready var axe: Sprite2D = $Axe
@onready var body_sprite: Sprite2D = $Sprite2D
@onready var swing_sound: AudioStreamPlayer = AudioStreamPlayer.new()

signal pickaxe_hit(hit_position: Vector2, direction: float)

var shards_collected: int:
	get: return GameState.shards_collected
	set(v): GameState.shards_collected = v

var health: int:
	get: return GameState.health
	set(v): GameState.health = v

func _ready() -> void:
	swing_sound.stream = load("res://echoveil/music/animations/axe swing.mp3")
	swing_sound.volume_db = -15.0
	add_child(swing_sound)

func _physics_process(delta: float) -> void:
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
		axe.scale.x = 0.08 if facing_right else -0.08
		axe.position.x = 60 if facing_right else -60
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)

	# PICKAXE SWING
	if Input.is_action_just_pressed("swing") and can_swing:
		swing_pickaxe()

	move_and_slide()

func swing_pickaxe() -> void:
	can_swing = false

	var swing_dir = 1.0 if facing_right else -1.0

	swing_sound.play()

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

	for result in results:
		var body = result.collider
		if body.has_method("take_damage"):
			body.take_damage(PICKAXE_DAMAGE)

	# Cooldown timer
	await get_tree().create_timer(0.3).timeout
	can_swing = true
