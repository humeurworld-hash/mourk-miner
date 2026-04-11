extends StaticBody2D

var health: int = 2
var shard_scene: PackedScene = null

func _ready() -> void:
	# Load the shard scene (we will create this next)
	shard_scene = load("res://shard.tscn")

func take_damage(amount: int) -> void:
	health -= amount

	if health <= 0:
		spawn_shards()
		queue_free()
		return

	# Visual feedback: shake the rock (only when still alive)
	var tween = create_tween()
	tween.tween_property(self, "position",
		position + Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.05)
	tween.tween_property(self, "position",
		position, 0.05)

func spawn_shards() -> void:
	# Drop 2 shards when the rock breaks
	for i in range(2):
		if shard_scene:
			var shard = shard_scene.instantiate()
			shard.position = global_position + Vector2(
				randf_range(-15, 15), randf_range(-10, 0))
			get_parent().add_child(shard)
