extends CanvasLayer

signal reward_collected(reward_type: int)

var _reward: int = 0

func setup(reward_type: int) -> void:
	_reward = reward_type

func _ready() -> void:
	layer = 20

	var viewport_size = get_viewport().get_visible_rect().size

	# Dark background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0)
	bg.size = viewport_size
	add_child(bg)

	# Reward icon
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var icon_size := Vector2(260, 160)
	icon.size = icon_size
	icon.pivot_offset = icon_size / 2.0
	icon.position = viewport_size / 2.0 - icon_size / 2.0
	icon.scale = Vector2(0.1, 0.1)
	icon.modulate.a = 0.0

	match _reward:
		0:  # 15 mourk shards
			var at := AtlasTexture.new()
			at.atlas = load("res://echoveil/UI/mourk counter/220E297F-BA40-4195-9E91-D295DD553BA9-2.png")
			at.region = Rect2(120, 399, 697, 229)
			icon.texture = at
		1:  # 3 power shards
			icon.texture = load("res://echoveil/platforms/Rocks and chest/26BD4AED-AB96-4AD0-B798-DAE0D240A86D 2.png")
		2:  # extra life
			var at := AtlasTexture.new()
			at.atlas = load("res://echoveil/UI/Life shards/220E297F-BA40-4195-9E91-D295DD553BA9-1.png")
			at.region = Rect2(913, 413, 119, 230)
			icon.texture = at

	add_child(icon)

	# Reward label
	var label := Label.new()
	label.name = "RewardLabel"
	var reward_texts := ["+ 15 MOURK SHARDS", "+ 3 POWER SHARDS", "+ EXTRA LIFE"]
	label.text = reward_texts[_reward]
	label.add_theme_font_size_override("font_size", 28)
	label.modulate.a = 0.0
	label.position = Vector2(viewport_size.x / 2.0 - 150.0, viewport_size.y / 2.0 + 95.0)
	add_child(label)

	_run_sequence(bg, icon, label, viewport_size)

func _run_sequence(bg: ColorRect, icon: TextureRect, label: Label, viewport_size: Vector2) -> void:
	var tween := create_tween()

	# Fade in dark bg
	tween.tween_property(bg, "color:a", 0.75, 0.35)

	# Pop icon in with bounce
	tween.tween_property(icon, "modulate:a", 1.0, 0.10)
	tween.parallel().tween_property(icon, "scale", Vector2(1.2, 1.2), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.10)

	# Fade in label at same time
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.20)

	# Hold so player can read it
	tween.tween_interval(1.5)

	# Give the reward now (before flying away)
	tween.tween_callback(func(): reward_collected.emit(_reward))

	# Fly-to target on HUD
	var target: Vector2
	match _reward:
		0:  target = Vector2(132.0, 48.0)
		1:  target = Vector2(viewport_size.x / 2.0, 48.0)
		2:  target = Vector2(viewport_size.x - 25.0, 35.0)

	# Icon flies to HUD, shrinks, fades; bg + label fade out together
	tween.tween_property(icon, "position", target, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(icon, "scale", Vector2(0.15, 0.15), 0.55)
	tween.parallel().tween_property(icon, "modulate:a", 0.0, 0.40)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.30)
	tween.parallel().tween_property(bg, "color:a", 0.0, 0.50)

	tween.tween_callback(func(): queue_free())
