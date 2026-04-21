extends Node

@export var joy_dict: Dictionary[String, JoyIcons]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prints("[CONTROLLER] ->", Input.get_joy_name(0))


func update_me() -> void:
	pass
