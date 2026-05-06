extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

@export var anim_player: AnimationPlayer
@export var torches: Node3D

func real_player_game()-> void:
	get_tree().change_scene_to_file("res://scenes/_levels/menus/main_menu/Main_Menu_UI_NEW/MainMenuScene_NEW_UI.tscn")

func play_game() -> void:
	anim_player.play("fade_out")

func kill_torches() -> void:
	torches.queue_free()
