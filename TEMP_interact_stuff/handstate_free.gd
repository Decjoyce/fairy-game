class_name HandState_Free
extends HandState

func handle_input(_event: InputEvent) -> void:
	#if _event.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): interact_func
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): interact()
	
	hand_controller.hovering_interactable = hand_controller.interact_checker()

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	pass

func exit() -> void:
	pass

func interact() -> void:
	print("hey")
	if !hand_controller.hovering_interactable:
		return
	hand_controller.begin_interact()
