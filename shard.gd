extends Area2D

var bob_offset: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	start_y = position.y
	bob_offset = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Float up and down gently
	bob_offset += delta * 3.0
	position.y = start_y + sin(bob_offset) * 4.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Add to player's shard count
		if body.has_method("collect_shard"):
			body.collect_shard()
		else:
			body.shards_collected += 1
		# Delete the shard
		queue_free()
