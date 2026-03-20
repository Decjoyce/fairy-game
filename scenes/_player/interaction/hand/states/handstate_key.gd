class_name HandState_Key
extends HandState

var keyhole: Keyhole
var current_value: float

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.hovering_interactable = null
	keyhole = hand_controller.current_interactable
	current_value = keyhole.current_value
	og_screen_pos = hand_controller.global_position
	if hand_controller.hand_type == 0: dir_to_turn = 1
	else: dir_to_turn = -1
	update_graphics(0)
	hand_controller.input_controls.disable_interact_action()

func exit() -> void:
	cur_angle = 0
	prev_angle = 0
	inserted_key = false
	input_vector = Vector2.ZERO
	y_axis = 0
	has_turned_clockwise = false

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type) or Input.is_action_just_pressed("use_" + hand_controller.stringed_hand_type): 
		finished.emit(FREE)
	
	controls(_delta)

func physics_update(_delta: float) -> void:
	pass

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

var cur_angle: float
var prev_angle: float
var inserted_key: bool
var turn_speed: float = 50
var input_vector: Vector2
var y_axis: float
var has_turned_clockwise: bool

var dir_to_turn: int

func controls(_delta: float) -> void:
	input_vector = Input.get_vector(hand_controller.stringed_hand_type + "_joystick_down", hand_controller.stringed_hand_type + "_joystick_up", hand_controller.stringed_hand_type + "_joystick_left", hand_controller.stringed_hand_type + "_joystick_right")
	y_axis= Input.get_axis(hand_controller.stringed_hand_type + "_joystick_down", hand_controller.stringed_hand_type + "_joystick_up")
	prev_angle = cur_angle
	cur_angle = rad_to_deg(input_vector.angle()) * dir_to_turn
	update_graphics(_delta)
	if !inserted_key:
		if y_axis > 0.9: 
			inserted_key = true
		elif current_value > 0: 
			has_turned_clockwise = false
			current_value = clampf(lerpf(current_value, -0.5, turn_speed * _delta), 0, 1.0)
	else:
		if input_vector.length() < 0.5: 
			inserted_key = false
			has_turned_clockwise = false
			return
		if cur_angle < 0 and is_turning_clockwise(): has_turned_clockwise = true
		if cur_angle <= 20 and cur_angle > 0 and !is_turning_clockwise(): has_turned_clockwise = false 
		calc_value(_delta)

func calc_value(_delta: float) -> void:
	if has_turned_clockwise: return
	var converted_angle:= clampf(cur_angle/135, 0, 1.1)
	current_value = clampf(lerpf(current_value, converted_angle, turn_speed * _delta), 0, 1.0)
	#prints(prev_angle, cur_angle, converted_angle, current_value)
	update_graphics(_delta)
	if current_value == 1.0:
		keyhole.activate()
		finished.emit(FREE)

func is_turning_clockwise() -> bool:
	#var dir := cur_angle - prev_angle
	return prev_angle >= cur_angle

# ↑ Control Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

var og_screen_pos: Vector2

func update_graphics(_delta: float) -> void:
	var screen_pos_inserted:= get_viewport().get_camera_3d().unproject_position(keyhole.hand_pos_inserted.global_position)
	var screen_pos_initial:= get_viewport().get_camera_3d().unproject_position(keyhole.hand_pos_initial.global_position)
	screen_pos_inserted -= Vector2(hand_controller.size.x/2, hand_controller.size.y/2)
	screen_pos_initial -= Vector2(hand_controller.size.x/2, hand_controller.size.y/2)
	if !inserted_key:
		#print(lerp(screen_pos_initial, screen_pos_inserted, y_axis * _delta))
		hand_controller.position = lerp(screen_pos_initial, screen_pos_inserted, y_axis)
	else:
		hand_controller.position = screen_pos_inserted
	update_hand_sprite() 

func update_hand_sprite() -> void:
	if current_value < 0.1 and !inserted_key:
		hand_controller.anim_change_idle_anim("hand_key_idle")
	elif current_value < 0.3:
		hand_controller.anim_change_idle_anim("hand_key_up")
	elif current_value <= 0.9:
		hand_controller.anim_change_idle_anim("hand_key_mid")
	else:
		hand_controller.anim_change_idle_anim("hand_key_down")
