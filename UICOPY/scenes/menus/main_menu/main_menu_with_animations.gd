extends MainMenu
## Main menu extension that animates the title and menu fading in.
## The animation can be skipped by the player with any input.

var animation_state_machine : AnimationNodeStateMachinePlayback
########################## NEW MIKE CODE FOR MAKING THE THING SMOOTH ###################################################################
@export var anim_player: AnimationPlayer 
@export var fade_anim: AnimationPlayer 
@export var vs_scnee: PackedScene
@export var demo_scnee: PackedScene
@export var demo_bb: PackedScene
#####################################################################################################################################
func intro_done() -> void:
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro() -> bool:
	return animation_state_machine.get_current_node() == "Intro"

func _event_skips_intro(event : InputEvent) -> bool:
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu : PackedScene) -> Node:
	animation_state_machine.travel("OpenSubMenu")
	return super._open_sub_menu(menu)

func _close_sub_menu() -> void:
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event : InputEvent) -> void:
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _ready() -> void:
	super._ready()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _on_continue_game_button_pressed() -> void:
	load_game_scene()

########################## NEW MIKE CODE FOR MAKING THE THING SMOOTH ####################################################################
func _on_playground_pressed() -> void:
	start_game(vs_scnee)
	pass # Replace with function body.
	

func start_game(scene):
	
	anim_player.play("SpeedIntoCavee") 
	animation_state_machine.travel("IntroB")
	visible = false
	
	await anim_player.animation_finished

	fade_anim.play("FadetoBlack")
	await fade_anim.animation_finished

	get_tree().change_scene_to_packed(scene)


func _on_play_demo_pressed() -> void:
	start_game(demo_scnee)
	pass # Replace with function body.


func _on_play_BB_pressed() -> void:
	start_game(demo_bb)
	pass # Replace with function body.
