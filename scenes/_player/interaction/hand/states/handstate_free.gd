class_name HandState_Free
extends HandState

var hovering_int: Interactable

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): 
		interact()
		return
	
	#if Input.is_action_just_pressed("enter_paint_mode_" + hand_controller.stringed_hand_type):
		#finished.emit(ATTACK)
		#return
	
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


func interact() -> void:
	#print("hey")
	if !hand_controller.hovering_interactable:
		return
	hand_controller.begin_interact()
