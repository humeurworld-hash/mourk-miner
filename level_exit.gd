extends Area2D

@export var next_scene: String = "res://level2.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameState.save()
		# Must defer — can't remove CollisionObjects during a physics callback
		get_tree().call_deferred("change_scene_to_file", next_scene)
