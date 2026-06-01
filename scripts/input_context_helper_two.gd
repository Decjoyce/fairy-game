extends Node

@export var joy_dict: Dictionary[String, Control]

@export var controller_image: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prints("[CONTROLLER] ->", Input.get_joy_name(0))
	update_me()


func update_me() -> void:
	if joy_dict.has(Input.get_joy_name(0)): set_icons(Input.get_joy_name(0))
	else:  set_icons("DEFAULT")

func set_icons(joy_name: String) -> void:
	for i in get_child(0).get_children():
		i.visible = false
	
	joy_dict[joy_name].visible = true
