extends Node

@export var joy_dict: Dictionary[String, JoyIcons]

@export var interact_action_left: TextureRect
@export var interact_action_right: TextureRect

@export var use_action_left: TextureRect
@export var use_action_right: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prints("[CONTROLLER] ->", Input.get_joy_name(0))
	update_me()


func update_me() -> void:
	if joy_dict.has(Input.get_joy_name(0)): set_icons(joy_dict[Input.get_joy_name(0)])
	else:  set_icons(joy_dict["DEFAULT"])

func set_icons(icons: JoyIcons) -> void:
	interact_action_left.texture = icons.trigger_left
	interact_action_right.texture = icons.trigger_right
	
	use_action_left.texture = icons.button_west
	use_action_right.texture = icons.button_east
