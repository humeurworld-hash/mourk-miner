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
	if body.name == "Player":
		_fly_to_counter()

func _fly_to_counter() -> void:
	# Capture before freeing
	var screen_pos = get_viewport().get_canvas_transform() * global_position
	var texture = $Sprite2D.texture
	var parent = get_parent()

	# Play collect sound
	var collect_sound = AudioStreamPlayer.new()
	collect_sound.stream = load("res://echoveil/music/animations/shard revel.mp3")
	parent.add_child(collect_sound)
	collect_sound.play()
	collect_sound.finished.connect(collect_sound.queue_free)

	# Free shard immediately
	queue_free()

	# Temporary screen-space sprite for the fly animation
	var anim_layer = CanvasLayer.new()
	anim_layer.layer = 20
	parent.add_child(anim_layer)

	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(0.035, 0.035)
	sprite.position = screen_pos
	anim_layer.add_child(sprite)

	# ShardIcon center on screen (offset_left=15 + half of 32px wide)
	var target = Vector2(31, 26)

	var tween = anim_layer.create_tween()
	tween.set_parallel(true)
	# Pop up briefly then fly
	tween.tween_property(sprite, "scale", Vector2(0.055, 0.055), 0.08)
	tween.chain().set_parallel(true)
	tween.tween_property(sprite, "position", target, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2(0.008, 0.008), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		GameState.shards_collected += 1
		# Every 25 shards grant 1 life (up to max 3)
		if GameState.shards_collected % 25 == 0 and GameState.health < 3:
			GameState.health = min(3, GameState.health + 1)
		anim_layer.queue_free()
	)
