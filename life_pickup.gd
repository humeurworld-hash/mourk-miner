extends Area2D

var bob_offset: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	start_y = position.y
	bob_offset = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	bob_offset += delta * 3.0
	position.y = start_y + sin(bob_offset) * 4.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and GameState.lives < 3:
		_fly_to_hud()
	elif body.name == "Player":
		queue_free()

func _fly_to_hud() -> void:
	var screen_pos = get_viewport().get_canvas_transform() * global_position
	var texture = $Sprite2D.texture
	var parent = get_parent()
	queue_free()

	var anim_layer = CanvasLayer.new()
	anim_layer.layer = 20
	parent.add_child(anim_layer)

	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(0.035, 0.035)
	sprite.modulate = Color(1.2, 0.0, 1.2, 1)
	sprite.position = screen_pos
	anim_layer.add_child(sprite)

	# Target: HealthLabel area top-right (~same y as health diamonds)
	var vp_width = anim_layer.get_viewport().get_visible_rect().size.x
	var target = Vector2(vp_width - 150, 26)

	var tween = anim_layer.create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(0.055, 0.055), 0.08)
	tween.chain().set_parallel(true)
	tween.tween_property(sprite, "position", target, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2(0.008, 0.008), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		GameState.lives = min(3, GameState.lives + 1)
		anim_layer.queue_free()
	)
