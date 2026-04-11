extends Area2D

var patrol_speed: float = 80.0
var patrol_range: float = 180.0
var start_x: float = 0.0
var start_y: float = 0.0
var direction: float = 1.0
var hover_time: float = 0.0
var damage_cooldown: float = 0.0
var stunned: bool = false
var stun_timer: float = 0.0
var stun_tween: Tween = null

func _ready() -> void:
	add_to_group("drone")
	start_x = position.x
	start_y = position.y
	hover_time = randf() * TAU

func _process(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta

	if stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			_end_stun()
		return

	# Patrol left/right
	position.x += patrol_speed * direction * delta
	if abs(position.x - start_x) >= patrol_range:
		direction *= -1
		$Sprite2D.flip_h = direction < 0

	# Hover up and down
	hover_time += delta * 2.5
	position.y = start_y + sin(hover_time) * 12.0

	# Damage player on contact
	if damage_cooldown <= 0:
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				GameState.health = max(0, GameState.health - 1)
				damage_cooldown = 1.5
				_flash_player(body)
				break

func stun(duration: float) -> void:
	# Kill any running stun tween before starting a new one
	if stun_tween:
		stun_tween.kill()
	stunned = true
	stun_timer = duration
	var loops = max(1, int(duration / 0.3))
	stun_tween = create_tween().set_loops(loops)
	stun_tween.tween_property(self, "modulate", Color(0.4, 0.6, 1.0, 0.6), 0.15)
	stun_tween.tween_property(self, "modulate", Color(0.6, 0.8, 1.0, 0.4), 0.15)

func _end_stun() -> void:
	stunned = false
	stun_timer = 0.0
	if stun_tween:
		stun_tween.kill()
		stun_tween = null
	modulate = Color(1, 1, 1, 1)

func take_damage(_amount: int) -> void:
	# Axe briefly stuns — only if not already stunned
	if not stunned:
		stun(1.5)

func _flash_player(player: Node) -> void:
	if player.has_node("AnimatedSprite2D"):
		var tween = create_tween()
		tween.tween_property(player.get_node("AnimatedSprite2D"), "modulate", Color(1, 0.2, 0.2, 1), 0.1)
		tween.tween_property(player.get_node("AnimatedSprite2D"), "modulate", Color(1, 1, 1, 1), 0.2)
