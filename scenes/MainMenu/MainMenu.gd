extends Node3D

@onready var anim_player: AnimationPlayer = $Camera3D/AnimationPlayer
#@onready var fade_anim: AnimationPlayer = $FadeLayer/AnimationPlayer

var game_started := false

@export var vs_scnee: PackedScene

#func _ready():
	#anim_player.play("CameraSlow")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

@export var light: Light3D

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		anim_player.play("SpeedIntoCavee_2")
	if Input.is_action_just_pressed("turn_left"):
		anim_player.play("RESET")
		#anim_player.play("CameraSlow")
	if Input.is_action_just_pressed("turn_right"):
		anim_player.play("CameraSlow")
		#anim_player.play("CameraSlow")
	
	return
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = Debug.cam.project_ray_origin(mousepos)
	var end = origin + Debug.cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result: return
	light.global_position = result.position

func start_game():
	anim_player.play("SpeedIntoCavee") 

	await anim_player.animation_finished

	#fade_anim.play("FadetoBlack")
	#await fade_anim.animation_finished

	get_tree().change_scene_to_packed(vs_scnee)
