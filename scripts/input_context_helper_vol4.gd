extends Node

@export var joy_dict: Dictionary[String, JoyIcons]

@export var skip_image: TextureRect
@export var confirm_image: TextureRect
@export var back_image: TextureRect
@export var select_image: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prints("[CONTROLLER] ->", Input.get_joy_name(0))
	update_me()


func update_me() -> void:
	if joy_dict.has(Input.get_joy_name(0)): set_icons(joy_dict[Input.get_joy_name(0)])
	else:  set_icons(joy_dict["DEFAULT"])

func set_icons(icons: JoyIcons) -> void:
	confirm_image.texture = icons.button_east
	back_image.texture = icons.button_south
	select_image.texture = icons.Lstick

func hide_me() -> void:
	skip_image.visible = false
