extends Node3D

@export var game_scene: PackedScene

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func play_game() -> void:
	get_tree().change_scene_to_packed(game_scene)
