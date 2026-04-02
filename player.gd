extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -400.0
const GRAVITY = 980.0
const PICKAXE_RANGE = 60.0
const PICKAXE_DAMAGE = 1

var shards_collected: int = 0
var can_swing: bool = true
var facing_right: bool = true

signal pickaxe_hit(hit_position: Vector2, direction: float)

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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)

	# PICKAXE SWING
	if Input.is_action_just_pressed("swing") and can_swing:
		swing_pickaxe()

	move_and_slide()

func swing_pickaxe() -> void:
	can_swing = false

	# Determine swing direction
	var swing_dir = 1.0 if facing_right else -1.0
	var hit_pos = global_position + Vector2(PICKAXE_RANGE * swing_dir, 0)

	# Check for rocks in range
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = hit_pos
	query.collision_mask = 2
	var results = space.intersect_point(query)

	for result in results:
		var body = result.collider
		if body.has_method("take_damage"):
			body.take_damage(PICKAXE_DAMAGE)

	# Cooldown timer
	await get_tree().create_timer(0.3).timeout
	can_swing = true
