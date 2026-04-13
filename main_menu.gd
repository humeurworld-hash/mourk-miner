extends Node2D

var can_interact: bool = false

func _ready() -> void:
	_build_background()
	_build_ui()
	_start_music()
	TransitionLayer.fade_in(0.6)
	await get_tree().create_timer(0.4).timeout
	can_interact = true

func _build_background() -> void:
	var parallax = Parallax2D.new()
	add_child(parallax)

	var far_layer = ParallaxLayer.new()
	far_layer.motion_scale = Vector2(0.15, 0.0)
	parallax.add_child(far_layer)

	var far_sprite = Sprite2D.new()
	far_sprite.texture = load("res://echoveil/backgrounds/farback.PNG")
	far_sprite.position = Vector2(525, 362)
	far_layer.add_child(far_sprite)

	var near_layer = ParallaxLayer.new()
	near_layer.motion_scale = Vector2(0.4, 0.0)
	near_layer.position = Vector2(46, 521)
	parallax.add_child(near_layer)

	var near_sprite = Sprite2D.new()
	near_sprite.texture = load("res://echoveil/backgrounds/foreground.png")
	near_sprite.position = Vector2(479, 53)
	near_sprite.scale = Vector2(1.0, 0.9114)
	near_layer.add_child(near_sprite)

func _build_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)

	# Dark overlay for readability
	var overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.06, 0.62)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)

	# Root control fills viewport
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	# --- Title ---
	var title = Label.new()
	title.text = "MOURK\nMINER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 88)
	title.add_theme_color_override("font_color", Color(0.85, 0.32, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.25, 0.0, 0.55, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 4)
	title.add_theme_constant_override("shadow_offset_y", 5)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color(0.45, 0.0, 0.75, 0.55))
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.anchor_top = 0.0
	title.anchor_bottom = 0.0
	title.offset_left = -230
	title.offset_right = 230
	title.offset_top = 50
	title.offset_bottom = 290
	root.add_child(title)

	# Title pulse glow
	var pulse = create_tween().set_loops()
	pulse.tween_property(title, "modulate", Color(1.1, 0.65, 1.0), 1.5).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(title, "modulate", Color(0.85, 0.32, 1.0), 1.5).set_trans(Tween.TRANS_SINE)

	# --- Subtitle ---
	var sub = Label.new()
	sub.text = "dig deep.  survive."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.45, 0.82, 1.0, 0.8))
	sub.anchor_left = 0.5
	sub.anchor_right = 0.5
	sub.anchor_top = 0.0
	sub.anchor_bottom = 0.0
	sub.offset_left = -180
	sub.offset_right = 180
	sub.offset_top = 272
	sub.offset_bottom = 310
	root.add_child(sub)

	# --- Buttons ---
	var box = VBoxContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -145
	box.offset_right = 145
	box.offset_top = 35
	box.offset_bottom = 220
	box.add_theme_constant_override("separation", 20)
	root.add_child(box)

	var has_save = FileAccess.file_exists("user://mourk_save.json")
	if has_save:
		_make_btn(box, "CONTINUE", _on_continue)
		_make_btn(box, "NEW GAME", _on_new_game)
	else:
		_make_btn(box, "PLAY", _on_continue)

	# --- Version label ---
	var ver = Label.new()
	ver.text = "mourk miner  v0.1"
	ver.add_theme_font_size_override("font_size", 13)
	ver.add_theme_color_override("font_color", Color(0.5, 0.4, 0.65, 0.55))
	ver.anchor_left = 0.5
	ver.anchor_right = 0.5
	ver.anchor_top = 1.0
	ver.anchor_bottom = 1.0
	ver.offset_left = -100
	ver.offset_right = 100
	ver.offset_top = -30
	ver.offset_bottom = -10
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(ver)

func _make_btn(parent: Node, label: String, cb: Callable) -> void:
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(290, 60)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.7, 0.15, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.45, 1.0))
	btn.add_theme_stylebox_override("normal", _style(Color(0.07, 0.04, 0.14, 0.92)))
	btn.add_theme_stylebox_override("hover", _style(Color(0.18, 0.06, 0.30, 1.0)))
	btn.add_theme_stylebox_override("pressed", _style(Color(0.30, 0.08, 0.44, 1.0)))
	btn.add_theme_stylebox_override("focus", _style(Color(0.18, 0.06, 0.30, 1.0)))
	btn.pressed.connect(cb)
	parent.add_child(btn)

func _style(color: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_border_width_all(2)
	s.border_color = Color(0.6, 0.12, 0.92, 0.7)
	s.set_corner_radius_all(10)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

func _start_music() -> void:
	var music = AudioStreamPlayer.new()
	music.stream = load("res://echoveil/music/Mist in the Circuit.mp3")
	music.volume_db = -12.0
	add_child(music)
	music.play()

func _on_continue() -> void:
	if not can_interact:
		return
	can_interact = false
	GameState.load_data()
	TransitionLayer.fade_out(
		func(): get_tree().change_scene_to_file("res://gameclaude.tscn"),
		0.5
	)

func _on_new_game() -> void:
	if not can_interact:
		return
	can_interact = false
	GameState.reset()
	GameState.save()
	TransitionLayer.fade_out(
		func(): get_tree().change_scene_to_file("res://gameclaude.tscn"),
		0.5
	)
