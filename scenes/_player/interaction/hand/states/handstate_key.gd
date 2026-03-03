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
	controls_alt(_delta)
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type) or Input.is_action_just_pressed("use_" + hand_controller.stringed_hand_type): 
		finished.emit(FREE)

func physics_update(_delta: float) -> void:
	pass

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

func controls_alt(_delta: float) -> void:
	var cur_incr: float = 0
	var axis := Input.get_axis(hand_controller.stringed_hand_type + "_joystick_left", hand_controller.stringed_hand_type + "_joystick_right")
	if axis > 0:
		cur_incr += 1 - exp(-2 * _delta)
	elif axis < 0:
		cur_incr -= 1 - exp(-2 * _delta)
	else:
		if current_value > 0.0:
			cur_incr -= 1 - exp(-2 * _delta)
		else: return
	
	current_value = clampf(current_value + cur_incr, 0, 1.0)
	print(current_value)
	update_graphics()
	if current_value == 1.0:
		keyhole.activate()
		finished.emit(FREE)

func update_graphics() -> void:
	var screen_pos:= get_viewport().get_camera_3d().unproject_position(keyhole.hand_pos.global_position)
	hand_controller.position = screen_pos - Vector2(hand_controller.size.x/2, hand_controller.size.y/2)
	update_hand_sprite() 

func update_hand_sprite() -> void:
	if current_value < 0.1:
		hand_controller.anim_change_idle_anim("hand_key_up")
	elif current_value <= 0.8:
		hand_controller.anim_change_idle_anim("hand_key_mid")
	else:
		hand_controller.anim_change_idle_anim("hand_key_down")
