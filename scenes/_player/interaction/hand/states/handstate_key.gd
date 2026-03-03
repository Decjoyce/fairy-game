class_name HandState_Key
extends HandState

var keyhole: Keyhole
var current_value: float

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.hovering_interactable = null
	keyhole = hand_controller.current_interactable
	current_value = keyhole.current_value
	update_graphics()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	controls(_delta)

func physics_update(_delta: float) -> void:
	pass

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

func controls(_delta: float) -> void:
	var cur_incr: float = 0
	if Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_right"):
		cur_incr += 1 - exp(-3 * _delta)
	elif Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_left"):
		cur_incr -= 1 - exp(-3 * _delta)
	else:
		cur_incr -= 1 - exp(-2 * _delta)
	
	current_value = clampf(current_value+cur_incr, 0, 1.0)
	print(current_value)
	keyhole.update_value(current_value)
	update_graphics()
	
	if current_value == 1.0:
		finished.emit(FREE)

func update_graphics() -> void:
	update_hand_sprite() 

func update_hand_sprite() -> void:
	if keyhole.current_value < 0.25:
		hand_controller.anim_change_idle_anim("hand_key_up")
	elif keyhole.current_value <= 0.75:
		hand_controller.anim_change_idle_anim("hand_lever_mid_side")
	else:
		hand_controller.anim_change_idle_anim("hand_key_down")
