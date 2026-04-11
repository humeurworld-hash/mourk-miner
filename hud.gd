extends CanvasLayer

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	$ShardLabel.text = "x " + str(player.shards_collected)

	var health_str = ""
	for i in range(player.health):
		health_str += "♦ "
	$HealthLabel.text = health_str.strip_edges()
