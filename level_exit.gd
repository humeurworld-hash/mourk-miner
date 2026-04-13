extends Area2D

@export var next_scene: String = "res://level2.tscn"
var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	GameState.save()
	TransitionLayer.fade_out(
		func(): get_tree().call_deferred("change_scene_to_file", next_scene),
		0.4
	)
