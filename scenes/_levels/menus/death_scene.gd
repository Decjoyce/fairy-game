extends Node3D

@export var game_scene: PackedScene
@export var end_scene: PackedScene
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called when the node enters the scene tree for the first time.
func play_game() -> void:
	get_tree().change_scene_to_file("res://Vertical_Slice_Level_03.tscn")

func play_end() -> void:
	get_tree().change_scene_to_file("res://scenes/__prototyping/end_scene.tscn")
