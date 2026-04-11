extends CanvasLayer

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	$ShardLabel.text = "x " + str(player.shards_collected)

	# Health diamonds (cyan)
	var health_str = ""
	for i in range(player.health):
		health_str += "♦ "
	$HealthLabel.text = health_str.strip_edges()

	# Lives display + Break indicator
	var lives = GameState.lives
	if lives >= 5:
		$LivesLabel.text = "♦ BREAK"
		$LivesLabel.add_theme_color_override("font_color", Color(1.0, 0.0, 1.0, 1.0))
	else:
		var lives_str = ""
		for i in range(lives):
			lives_str += "♦ "
		$LivesLabel.text = lives_str.strip_edges()
		$LivesLabel.add_theme_color_override("font_color", Color(0.9, 0.3, 1.0, 1.0))
