class_name Interactable
extends Node3D

signal on_begin_interact(sig: float)
signal on_interacting(sig: float)
signal on_end_interact(sig: float)

enum InteractTypes {INSTANT, GRAB_ITEM, GRAB_OBJ, LEVER} # might move all the enums to a global class
@export var interaction_type : InteractTypes

enum PromptTypes {ITEM_PROMPT, LEVER_HOVER, OBJ_PROMPT, BUTTON_PROMPT}
@export var hand_prompt : PromptTypes

func begin_interact(sig: float = -1) -> void:
	pass

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	pass
