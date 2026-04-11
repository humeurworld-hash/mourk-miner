extends Area2D

@export var next_scene: String = "res://level2.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameState.save()
		get_tree().change_scene_to_file(next_scene)
