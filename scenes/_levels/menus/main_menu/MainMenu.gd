extends Node

@onready var anim_player: AnimationPlayer = $Camera3D/AnimationPlayer
@onready var fade_anim: AnimationPlayer = $FadeLayer/AnimationPlayer
@export var animation_state_machine : AnimationNodeStateMachinePlayback
@export var animationPlayer: AnimationPlayer
@export var SkipUI: TextureRect

var game_started := false

@export var vs_scnee: PackedScene
@export var Intro1: bool 
@export var Intro2: bool 

func _ready():
	#anim_player.play("CameraSlow")
	animation_state_machine = $MainMenu/MenuAnimationTree.get("parameters/playback")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _process(delta):
	skip_stuff()

func opening_done():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	animation_state_machine.travel("Intro")
	
var skipped: bool

func skip_stuff():
	pass
	if Intro1:
		if Input.is_anything_pressed() and !Input.is_action_just_pressed("dec_pause"):
			SkipUI.visible = true
			$SkipUI/hide.start()
		if Input.is_action_just_pressed("dec_pause"):
			SkipUI.visible = false
			skipped = true
			#$SkipUI/hide.stop()
			animation_state_machine.travel("Intro")
		elif Input.is_action_just_released("dec_pause"):
			$SkipUI/hide.start()
	else:
		SkipUI.visible = false
	
	#if Intro1:  #Is in intro?
		#if Input.is_anything_pressed(): #first press
			####turn the skip ? on 
			#SkipUI.visible = true
			#$SkipUI/hide.start(6)
			#await $SkipUI/hide.timeout
			#SkipUI.visible = false
	#
		#if Input.is_action_just_pressed("toggle_crouch"):# Second cofirm press
			#$SkipUI/Timer.start(2)
			#await $SkipUI/Timer.timeout
			#Intro2 = true
				#
		#if Input.is_action_just_released("toggle_crouch"):
			#$SkipUI/Timer.stop()
			#Intro2 = false



func start_game():
	anim_player.play("SpeedIntoCavee") 

	await anim_player.animation_finished

	fade_anim.play("FadetoBlack")
	await fade_anim.animation_finished

	get_tree().change_scene_to_packed(vs_scnee)
