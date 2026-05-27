extends Node

@export var joy_dict: Dictionary[String, JoyIcons]

@export var skip_image: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prints("[CONTROLLER] ->", Input.get_joy_name(0))
	update_me()


func update_me() -> void:
	if joy_dict.has(Input.get_joy_name(0)): set_icons(joy_dict[Input.get_joy_name(0)])
	else:  set_icons(joy_dict["DEFAULT"])

func set_icons(icons: JoyIcons) -> void:
	skip_image.texture = icons.pause_button

func hide_me() -> void:
	skip_image.visible = false
