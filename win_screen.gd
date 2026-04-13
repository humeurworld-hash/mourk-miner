extends Node2D

func _ready() -> void:
	_build_background()
	_build_ui()
	TransitionLayer.fade_in(0.8)

func _build_background() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 0
	add_child(canvas)

	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.01, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)

	# Subtle glow overlay
	var glow = ColorRect.new()
	glow.color = Color(0.4, 0.0, 0.8, 0.0)
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(glow)

	var pulse = create_tween().set_loops()
	pulse.tween_property(glow, "color", Color(0.4, 0.0, 0.8, 0.07), 2.0).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "color", Color(0.4, 0.0, 0.8, 0.0), 2.0).set_trans(Tween.TRANS_SINE)

func _build_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	# --- Title ---
	var title = Label.new()
	title.text = "YOU ESCAPED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.85, 0.55, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.5, 0.0, 1.0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 5)
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.anchor_top = 0.0
	title.anchor_bottom = 0.0
	title.offset_left = -320
	title.offset_right = 320
	title.offset_top = 80
	title.offset_bottom = 175
	root.add_child(title)

	var pulse = create_tween().set_loops()
	pulse.tween_property(title, "modulate", Color(1.1, 0.7, 1.0), 1.8).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(title, "modulate", Color(0.85, 0.45, 1.0), 1.8).set_trans(Tween.TRANS_SINE)

	# --- Subtitle ---
	var sub = Label.new()
	sub.text = "PrimeMourk is destroyed."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.45, 0.82, 1.0, 0.85))
	sub.anchor_left = 0.5
	sub.anchor_right = 0.5
	sub.anchor_top = 0.0
	sub.anchor_bottom = 0.0
	sub.offset_left = -220
	sub.offset_right = 220
	sub.offset_top = 185
	sub.offset_bottom = 220
	root.add_child(sub)

	# --- Shard count ---
	var shard_line = Label.new()
	shard_line.text = "Shards collected:  " + str(GameState.shards_collected)
	shard_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shard_line.add_theme_font_size_override("font_size", 30)
	shard_line.add_theme_color_override("font_color", Color(0.95, 0.82, 0.28, 1))
	shard_line.anchor_left = 0.5
	shard_line.anchor_right = 0.5
	shard_line.anchor_top = 0.5
	shard_line.anchor_bottom = 0.5
	shard_line.offset_left = -220
	shard_line.offset_right = 220
	shard_line.offset_top = -60
	shard_line.offset_bottom = -15
	root.add_child(shard_line)

	# --- Menu button ---
	var btn = Button.new()
	btn.text = "RETURN TO MENU"
	btn.custom_minimum_size = Vector2(300, 62)
	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.7, 0.15, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.45, 1.0))
	btn.add_theme_stylebox_override("normal", _style(Color(0.07, 0.04, 0.14, 0.92)))
	btn.add_theme_stylebox_override("hover", _style(Color(0.18, 0.06, 0.30, 1.0)))
	btn.add_theme_stylebox_override("pressed", _style(Color(0.30, 0.08, 0.44, 1.0)))
	btn.add_theme_stylebox_override("focus", _style(Color(0.18, 0.06, 0.30, 1.0)))
	btn.anchor_left = 0.5
	btn.anchor_right = 0.5
	btn.anchor_top = 0.5
	btn.anchor_bottom = 0.5
	btn.offset_left = -150
	btn.offset_right = 150
	btn.offset_top = 30
	btn.offset_bottom = 95
	btn.pressed.connect(_on_menu)
	root.add_child(btn)

func _style(color: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_border_width_all(2)
	s.border_color = Color(0.6, 0.12, 0.92, 0.7)
	s.set_corner_radius_all(10)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

func _on_menu() -> void:
	GameState.reset()
	TransitionLayer.fade_out(
		func(): get_tree().call_deferred("change_scene_to_file", "res://main_menu.tscn"),
		0.5
	)
