extends CanvasLayer

# Pixel crop bounds for each number image (x, y, w, h) on 1536x1024 canvas
const NUM_REGIONS = [
	[183, 206, 163, 186],  # 0
	[454, 207, 124, 185],  # 1
	[689, 207, 159, 185],  # 2
	[944, 207, 162, 185],  # 3
	[1193, 207, 174, 185], # 4
	[168, 553, 167, 180],  # 5
	[425, 553, 166, 180],  # 6
	[684, 553, 147, 180],  # 7
	[1201, 552, 166, 181], # 8
	[944, 555, 199, 177],  # 9
	[139, 806, 249, 181],  # 10
]

var _num_textures: Array = []
var _num_rect: TextureRect = null

func _ready() -> void:
	TransitionLayer.fade_in(0.5)

	# Build cropped AtlasTexture for each digit
	for i in range(11):
		var img = load("res://echoveil/UI/mourk counter/numbers/Numbers/" + str(i) + ".png")
		var at = AtlasTexture.new()
		at.atlas = img
		var b = NUM_REGIONS[i]
		at.region = Rect2(b[0], b[1], b[2], b[3])
		_num_textures.append(at)

	# Hide text label — replaced by image number
	$ShardLabel.visible = false

	# Number display overlaid on the blank area of the mourk counter tablet
	# (ShardIcon spans offset 10→254 / 8→88; blank rect is right 55% of that)
	_num_rect = TextureRect.new()
	_num_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_num_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_num_rect.offset_left = 128.0
	_num_rect.offset_top = 16.0
	_num_rect.offset_right = 250.0
	_num_rect.offset_bottom = 86.0
	add_child(_num_rect)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Number image counter
	var count = clamp(player.shards_collected, 0, 10)
	if _num_rect:
		_num_rect.texture = _num_textures[count]

	# Health crystals
	var health = player.health
	$HealthShard1.visible = health >= 1
	$HealthShard2.visible = health >= 2
	$HealthShard3.visible = health >= 3

	# Lives display + Break indicator
	var lives = GameState.lives
	if lives >= 3:
		$LivesLabel.text = "♦ BREAK"
		$LivesLabel.add_theme_color_override("font_color", Color(1.0, 0.0, 1.0, 1.0))
	else:
		var lives_str = ""
		for i in range(lives):
			lives_str += "♦ "
		$LivesLabel.text = lives_str.strip_edges()
		$LivesLabel.add_theme_color_override("font_color", Color(0.9, 0.3, 1.0, 1.0))
