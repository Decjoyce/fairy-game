class_name HandState_Chain
extends HandState

var current_value: float = 0
var chain: Chain
var pull_speed: float = 0.5


func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.hovering_interactable = null
	chain = hand_controller.current_interactable
	current_value = chain.current_value
	hand_controller.anim_change_idle_anim("hand_chain")
	
	var screen_pos:= get_viewport().get_camera_3d().unproject_position(chain.graphics.global_position)
	y_offset = screen_pos.y - hand_controller.global_position.y
	x_pos = screen_pos.x
	
	end_pos = get_viewport().get_camera_3d().unproject_position(chain.point_end).y
	top_pos = get_viewport().get_camera_3d().unproject_position(chain.point_top).y
	print(top_pos)
	update_graphics()

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	current_value = 0
	y_offset = 0
	x_pos = 0
	end_pos = 0
	top_pos = 0
	hand_controller.anim_change_idle_anim("a_hand_idle")

func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): 
		finished.emit(FREE)

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	controls(_delta)


# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Controls Stuff ↓

func controls(_delta: float) -> void:
	
	var cur_incr: float = 0
	if Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_down"):
		if !has_reached_limit_end():
			cur_incr += 1 - exp(-pull_speed * _delta)
	elif Input.is_action_pressed(hand_controller.stringed_hand_type + "_joystick_up"):
		if !has_reached_limit_top():
			cur_incr -= 1 - exp(-pull_speed * _delta)
	else: return
	
	current_value = clampf(current_value+cur_incr, 0, 1.0)
	chain.update_value(current_value)
	update_graphics()

var top_pos: float
var end_pos: float

func has_reached_limit_end() -> bool:
	return hand_controller.get_screen_position().y > end_pos - hand_controller.size.y

func has_reached_limit_top() -> bool:
	return hand_controller.get_screen_position().y < top_pos

# ↑ Controls Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

var y_offset: float
var x_pos: float


func update_graphics() -> void:
	var screen_pos:= get_viewport().get_camera_3d().unproject_position(chain.graphics.global_position)
	var new_pos := Vector2(screen_pos.x, screen_pos.y - y_offset)
	hand_controller.position = new_pos - Vector2(hand_controller.size.x/2, 0)
	
