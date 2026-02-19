class_name HandState_Lever
extends HandState

var current_value: float = 0
var lever: Lever

func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): 
		finished.emit(FREE)

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	controls(_delta)

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.hovering_interactable = null
	lever = hand_controller.current_interactable
	current_value = lever.current_value
	#hand_controller.anim_change_idle_anim("hand_prompt_lever")
	update_graphics()

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	current_value = 0
	pass

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

func controls(_delta: float) -> void:
	var cur_incr: float = 0
	if Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_down"):
		cur_incr += 1 - exp(-1 * _delta)
	elif Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_up"):
		cur_incr -= 1 - exp(-1 * _delta)
	else: return
	current_value = clampf(current_value+cur_incr, 0, 1.0)
	lever.update_value(current_value)
	update_graphics()

# ↑ Controls Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

func update_graphics() -> void:
	#print(calc_hand_pos())
	if get_viewport().get_camera_3d().is_position_behind(calc_hand_pos()): return
	var screen_pos:= get_viewport().get_camera_3d().unproject_position(calc_hand_pos())
	hand_controller.position = screen_pos - Vector2(hand_controller.size.x/2, hand_controller.size.y/2)
	update_hand_sprite()
	

func update_hand_sprite() -> void:
	if lever.current_value < 0.2:
		hand_controller.anim_change_idle_anim("hand_lever_up")
	elif lever.current_value <= 0.8:
		hand_controller.anim_change_idle_anim("hand_lever_mid")
	else:
		hand_controller.anim_change_idle_anim("hand_lever_down")

func calc_hand_pos() -> Vector3:
	#var y_pos = remap(current_value, 0, 1, lever.hand_pos_bottom.global_position.y, lever.hand_pos_top.global_position.y)
	#return Vector3(lever.hand_pos_bottom.global_position.)
	#return lerp(lever.hand_pos_top.global_position, lever.hand_pos_bottom.global_position, current_value)
	return _quardatic_bezier(lever.hand_pos_top.global_position, lever.hand_pos_mid.global_position, lever.hand_pos_bottom.global_position, lever.current_value)

func _quardatic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
