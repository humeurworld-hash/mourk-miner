extends StaticBody2D

signal prime_mourk_broken

var health = 5
var is_broken = false

func take_damage(amount):
	if is_broken:
		return
	health -= amount

	# Flash white on hit
	var tween = create_tween()
	tween.tween_property(self, "modulate",
		Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(self, "modulate",
		Color(1.0, 1.0, 1.0, 1.0), 0.1)

	if health <= 0:
		_break()

func _break():
	is_broken = true
	emit_signal("prime_mourk_broken")
	LevelManager.trigger_prime_mourk_event()

	# Big flash sequence
	var tween = create_tween()
	tween.tween_property(self, "modulate",
		Color(0.0, 5.0, 5.0, 1.0), 0.1)
	tween.tween_property(self, "modulate",
		Color(1.0, 1.0, 1.0, 0.0), 0.5)
	tween.tween_callback(queue_free)
