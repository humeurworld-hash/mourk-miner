extends CanvasLayer

func _on_left_down(): Input.action_press("ui_left")
func _on_left_up(): Input.action_release("ui_left")
func _on_right_down(): Input.action_press("ui_right")
func _on_right_up(): Input.action_release("ui_right")
func _on_jump_down(): Input.action_press("ui_accept")
func _on_jump_up(): Input.action_release("ui_accept")
func _on_swing_down(): Input.action_press("swing")
func _on_swing_up(): Input.action_release("swing")
