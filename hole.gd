extends Area2D

@export var target_scene: String = "res://level2.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	var segments := 48
	var rx := 64.0
	var ry := 20.0

	# Outer glow ring
	var glow_pts := PackedVector2Array()
	for i in range(segments):
		var a = i * TAU / segments
		glow_pts.append(Vector2(cos(a) * (rx + 10), sin(a) * (ry + 6)))
	draw_colored_polygon(glow_pts, Color(0.18, 0.08, 0.35, 0.55))

	# Main hole body
	var pts := PackedVector2Array()
	for i in range(segments):
		var a = i * TAU / segments
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, Color(0.06, 0.02, 0.10, 1.0))

	# Deep centre
	var inner_pts := PackedVector2Array()
	for i in range(segments):
		var a = i * TAU / segments
		inner_pts.append(Vector2(cos(a) * rx * 0.55, sin(a) * ry * 0.55))
	draw_colored_polygon(inner_pts, Color(0.0, 0.0, 0.0, 1.0))

	# Rim highlight (top arc)
	for i in range(segments / 2):
		var a = PI + i * PI / (segments / 2)
		var p1 = Vector2(cos(a) * rx, sin(a) * ry)
		var p2 = Vector2(cos(a) * (rx - 6), sin(a) * (ry - 3))
		draw_line(p1, p2, Color(0.55, 0.35, 0.85, 0.45), 1.5)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		TransitionLayer.fade_out(
			func(): get_tree().change_scene_to_file(target_scene),
			0.5
		)
