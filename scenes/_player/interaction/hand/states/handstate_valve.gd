class_name HandState_Valve
extends HandState

var current_value: float
var prev_angle: float

var valve: Valve

@export var deadzone: float = 0.8

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.hovering_interactable = null
	valve = hand_controller.current_interactable
	current_value = valve.current_value
	update_lever_direction()
	update_graphics()
	
	if valve.prev_angle != -1: prev_angle = valve.prev_angle 

func exit() -> void:
	current_value = 0
	valve.prev_angle = prev_angle
	valve = null
	hand_controller.anim_change_idle_anim("a_hand_idle")

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if player.movement.dist_to_target > 0:
		update_graphics()
	
	controls(_delta)
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): 
		finished.emit(FREE)

func physics_update(_delta: float) -> void:
	#controls(_delta)
	#controls_alt_alt(_delta)
	pass

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

func controls(_delta: float) -> void:
	var input_vec := Input.get_vector(hand_controller.stringed_hand_type + "_joystick_right", hand_controller.stringed_hand_type +  "_joystick_left", hand_controller.stringed_hand_type +  "_joystick_up", hand_controller.stringed_hand_type +  "_joystick_down")
	if input_vec.length_squared() < deadzone: 
		prev_angle = -1
		return
	if input_vec.distance_squared_to(prev_input) <= 0.01: return
	var new_angle := ceilf((rad_to_deg(input_vec.angle()) + 180))
	var cur_incr: float = 0
	if abs(new_angle - prev_angle) <= 0.1: return
	if new_angle > prev_angle:
		cur_incr -= 1 - exp(-7.5 * _delta)
	elif new_angle < prev_angle:
		cur_incr += 1 - exp(-7.5 * _delta)
	else: return
	
	current_value = clampf(current_value+cur_incr, 0, 1.0)
	#print(current_value)
	valve.update_value(current_value)
	update_graphics()
	prev_angle = new_angle
	prev_input = input_vec

#func controls_alt(_delta: float) -> void:
	#var input_vec := Input.get_vector("LEFT_joystick_left", "LEFT_joystick_right", "LEFT_joystick_down", "LEFT_joystick_up")
	#if input_vec.length_squared() < deadzone: 
		#prev_angle = -1
		#return
	#var new_angle := (ceilf((rad_to_deg(input_vec.angle()) + 180))/360)
	#
	#current_value = clampf(new_angle, 0, 1.0)
	#print(current_value)
	#valve.update_value(current_value)
	#update_graphics()

var cur_angle: float
var prev_input: Vector2
#
func controls_alt_alt(_delta: float) -> void:
	var input_dir := Input.get_vector(hand_controller.stringed_hand_type + "_joystick_right", hand_controller.stringed_hand_type +  "_joystick_left", hand_controller.stringed_hand_type +  "_joystick_up", hand_controller.stringed_hand_type +  "_joystick_down").normalized()
	if input_dir.length_squared() < deadzone: return
	#if current_value == 1.0 and prev_input  
	var new_angle: float = atan2(-input_dir.y, input_dir.x)
	new_angle = clampf(rad_to_deg(new_angle), -178, 178)
	cur_angle = lerpf(cur_angle, new_angle, 1 - exp(-1 * _delta))
	current_value = remap(cur_angle, -180, 180, 0, 1.0)
	
	
	#current_value = clampf(cur_angle, 0, 1.0)
	prints("inputdir:", input_dir, ":: newangle:", new_angle, ":: cur_angle:", cur_angle, ":: currentvalue", current_value)
	#print(current_value)
	valve.update_value(current_value)
	update_graphics()
	prev_input = input_dir
	

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

var dir_string: String # for animation

func update_graphics() -> void:
	var screen_pos:= get_viewport().get_camera_3d().unproject_position(valve.hand_pos.global_position)
	hand_controller.position = screen_pos - Vector2(hand_controller.size.x/2, hand_controller.size.y/2)

func update_lever_direction() -> void:
	var rot_dif: float = abs(player.movement.compass.global_rotation_degrees.y - valve.global_rotation_degrees.y)
	if (rot_dif < 45 and rot_dif > -45) or (rot_dif < 225 and rot_dif > 135): hand_controller.anim_change_idle_anim("hand_valve")
	else: hand_controller.anim_change_idle_anim("hand_valve_side")

#func calc_hand_pos() -> Vector3:
	#return _quardatic_bezier(valve.hand_pos_top.global_position, valve.hand_pos_mid.global_position, valve.hand_pos_bottom.global_position, valve.current_value)
#
#func _quardatic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	#var q0 = p0.lerp(p1, t)
	#var q1 = p1.lerp(p2, t)
	#var r = q0.lerp(q1, t)
	#return r
