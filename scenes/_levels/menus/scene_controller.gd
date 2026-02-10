extends Node3D

@export var the_scenes: Array[PackedScene]
@onready var main_button: Button = $Control/MarginContainer/VBoxContainer/Button
@onready var int_button: Button = $Control/MarginContainer/VBoxContainer/Button2
@onready var lit_button: Button = $Control/MarginContainer/VBoxContainer/Button3

func _ready() -> void:
	main_button.pressed.connect(change_scene_to_main)
	int_button.pressed.connect(change_scene_to_interact)
	lit_button.pressed.connect(change_scene_to_lit)

func change_scene_to_main() -> void:
	Debug.audio_player.play()
	get_tree().change_scene_to_packed(the_scenes[0])

func change_scene_to_interact() -> void:
	Debug.audio_player.play()
	get_tree().change_scene_to_packed(the_scenes[1])

func change_scene_to_lit() -> void:
	Debug.audio_player.play()
	get_tree().change_scene_to_packed(the_scenes[2])

func exit_to_menu() -> void:
	get_tree().change_scene_to_packed(the_scenes[0])
