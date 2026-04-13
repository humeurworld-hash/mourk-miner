extends Area2D

# 0 = 15 mourk shards, 1 = 3 power shards, 2 = extra life
var reward: int = 0
var opened: bool = false

func _ready() -> void:
	reward = randi() % 3
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if opened or not body.is_in_group("player"):
		return
	_open()

func _open() -> void:
	opened = true
	$AnimatedSprite2D.play("open")

func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation != &"open":
		return
	_give_reward()
	$AnimatedSprite2D.play("empty")

func _give_reward() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	match reward:
		0: # 15 mourk shards
			player.shards_collected += 15
		1: # 3 power shards
			if "power_shards" in player:
				player.power_shards += 3
		2: # extra life
			if "health" in player:
				player.health = min(player.health + 1, 3)
