extends Node

@onready var anim_player: AnimationPlayer = $Camera3D/AnimationPlayer
@onready var fade_anim: AnimationPlayer = $FadeLayer/AnimationPlayer

var game_started := false

func _ready():
	anim_player.play("CameraSlow")

func _process(delta):
	if game_started:
		return
	
	if Input.is_action_just_pressed("ui_StartButton"):
		game_started = true
		start_game()

func start_game():
	anim_player.play("SpeedIntoCavee") 

	await anim_player.animation_finished

	fade_anim.play("FadetoBlack")
	await fade_anim.animation_finished

	get_tree().change_scene_to_file("")
