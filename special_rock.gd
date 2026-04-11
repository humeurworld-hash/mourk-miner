extends StaticBody2D

var health: int = 2

func _ready() -> void:
	$Sprite2D.modulate = Color(1.5, 1.1, 0.1, 1)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_spawn_life()
		queue_free()
		return
	var tween = create_tween()
	tween.tween_property(self, "position",
		position + Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.05)
	tween.tween_property(self, "position", position, 0.05)

func _spawn_life() -> void:
	var life = load("res://life_pickup.tscn").instantiate()
	life.position = global_position + Vector2(0, -20)
	get_parent().add_child(life)
	var snd = AudioStreamPlayer.new()
	snd.stream = load("res://echoveil/music/animations/Rock break.mp3")
	get_parent().add_child(snd)
	snd.play()
	snd.finished.connect(snd.queue_free)
