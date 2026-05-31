class_name HandState_Free
extends HandState

var hovering_int: Interactable

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if MultiplayerInput.is_action_just_pressed(player.device,"change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if MultiplayerInput.is_action_just_pressed(player.device,"action_" + hand_controller.stringed_hand_type): 
		interact()
		return
	
	#if MultiplayerInput.is_action_just_pressed(player.device,"enter_paint_mode_" + hand_controller.stringed_hand_type):
		#finished.emit(ATTACK)
		#return
	
	set_model_position()
	
	var same_frame_check: int = 0
	
	hand_controller.hovering_interactable = hand_controller.interact_checker()
	if hand_controller.hovering_interactable:
		if hand_controller.anim_is_prompting: return
		hand_controller.anim_is_prompting = true
		hand_controller.input_controls.enable_interact_action(hand_controller.hovering_interactable.prompt_text)
		hand_controller.anim_change_prompt_anim(hand_controller.hovering_interactable.hand_prompt)
	else: 
		if !hand_controller.anim_is_prompting: return
		hand_controller.anim_is_prompting = false
		hand_controller.input_controls.disable_interact_action()
		hand_controller.anim_change_prompt_anim(anim_prompt)

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.anim_change_idle_anim(anim_idle)
	hand_controller.anim_change_prompt_anim(anim_prompt)
	hand_controller.input_controls.disable_interact_action()
	hand_controller.input_controls.disable_use_action()
	
	#print("hmm")

func exit() -> void:
	pass

@export var offset_helper: Control

const GRAB_DIST = 1.0
@export_flags_2d_physics var grab_ray_collision_mask: int

var _space_state: PhysicsDirectSpaceState3D
var is_against_wall: bool

func set_model_position() -> void:
	if !_space_state:
		_space_state = hand_controller.cam.get_world_3d().direct_space_state
	
	var origin := hand_controller.cam.project_ray_origin(offset_helper.get_screen_position())
	var end := origin + hand_controller.cam.project_ray_normal(offset_helper.global_position) * GRAB_DIST
	
	var query := PhysicsRayQueryParameters3D.create(origin, end, grab_ray_collision_mask) # probably want to add layer stuff later
	query.collide_with_areas = true
	
	var result = _space_state.intersect_ray(query)
	
	if !result or !result.collider:
		hand_controller.hand_model.global_position = end
		is_against_wall = false
	else:
		is_against_wall = true
		hand_controller.hand_model.global_position = result.position + (result.normal * 0.1)

func interact() -> void:
	#print("hey")
	if !hand_controller.hovering_interactable:
		return
	hand_controller.begin_interact()
