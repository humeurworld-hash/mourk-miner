extends CanvasLayer

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		$ShardLabel.text = "Shards: " + str(player.shards_collected)
