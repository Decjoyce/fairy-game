class_name HandState_Attack
extends HandState

@onready var timer: Timer = $Timer
var target: Tempp_Enemy
var stats: Stats

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("enter_paint_mode_" + hand_controller.stringed_hand_type):
		finished.emit(FREE)
		return
	
	target = hand_controller.interact_checker_enemy()
	if target:
		if !hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = true
			hand_controller.anim_change_prompt_anim(anim_prompt)
	else:
		if hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = false
			hand_controller.anim_change_prompt_anim(anim_prompt)
	
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type):
		attack()

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.anim_change_idle_anim(anim_idle)
	hand_controller.anim_change_prompt_anim(anim_prompt)
	player.change_to_combat()

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	target = null
	player.exit_to_combat()

func attack() -> void:
	if !timer.is_stopped(): 
		print("Stopped at timer")
		return
	if player.stats.current_stamina <= 0: 
		print("Stopped at stam")
		return
	print("wasnt stopped?")
	hand_controller.anim_override_current_animation("hand_attack")
	timer.start()
	player.stats.take_stamina(25.0)
	if target: target.take_damage(25)
