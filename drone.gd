extends Area2D

var health: int = 2
var patrol_speed: float = 80.0
var patrol_range: float = 180.0
var start_x: float = 0.0
var start_y: float = 0.0
var direction: float = 1.0
var hover_time: float = 0.0
var damage_cooldown: float = 0.0

func _ready() -> void:
	start_x = position.x
	start_y = position.y
	hover_time = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta

	# Patrol left/right
	position.x += patrol_speed * direction * delta
	if abs(position.x - start_x) >= patrol_range:
		direction *= -1
		$Sprite2D.flip_h = direction < 0

	# Hover up and down
	hover_time += delta * 2.5
	position.y = start_y + sin(hover_time) * 12.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and damage_cooldown <= 0:
		GameState.health = max(0, GameState.health - 1)
		damage_cooldown = 1.5
		# Flash player red briefly
		if body.has_node("Sprite2D"):
			var tween = create_tween()
			tween.tween_property(body.get_node("Sprite2D"), "modulate", Color(1, 0.2, 0.2, 1), 0.1)
			tween.tween_property(body.get_node("Sprite2D"), "modulate", Color(1, 1, 1, 1), 0.2)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		# Death flash then free
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15)
		tween.tween_callback(queue_free)
	else:
		# Hit flash
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 0.2, 0.2, 1), 0.08)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.08)
