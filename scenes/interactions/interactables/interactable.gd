class_name Interactable
extends Node3D

signal on_begin_interact(sig: float)
signal on_interacting(sig: float)
signal on_end_interact(sig: float)

enum InteractTypes {INSTANT, GRAB_ITEM, GRAB_OBJ, LEVER, TEMP_ATTACK, TEMP_KEYHOLE, TEMP_CHAIN, TEMP_VALVE, TEMP_SAVE} # might move all the enums to a global class
@export var interaction_type : InteractTypes

@export var hand_prompt : String = "hand_prompt_default"
@export var prompt_text: String = ""

@export var disabled: bool

func _ready() -> void:
	if disabled: disable()

func begin_interact(sig: float = -1) -> void:
	pass

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	pass

func enable(sig: float = -1) -> void:
	pass

func disable(sig: float = -1) -> void:
	pass
