class_name InputContexts
extends VBoxContainer

@onready var interact_action: Control = $InteractAction
@onready var interact_action_text: RichTextLabel = $InteractAction/RichTextLabel
@export var crouch_action: Control 
@export var crouch_action_text: RichTextLabel 

@onready var use_action: Control = $UseAction
@onready var use_action_text: RichTextLabel = $UseAction/RichTextLabel

func enable_interact_action(prompt: String) -> void:
	interact_action_text.text = prompt
	interact_action.visible = true

func disable_interact_action() -> void:
	interact_action.visible = false

func enable_use_action(prompt: String) -> void:
	use_action_text.text = prompt
	use_action.visible = true

func disable_use_action() -> void:
	use_action.visible = false
	
func enable_crouch_action() -> void:    # can put a prompt potentially 
	#crouch_action_text.text = prompt
	crouch_action.visible = true

func disable_crouch_action() -> void:
	crouch_action.visible = false
