extends Node3D

@export var game_scene: PackedScene

func play_game() -> void:
	get_tree().change_scene_to_packed(game_scene)
