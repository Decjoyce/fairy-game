class_name Interactable
extends Node3D

signal begin_interact(sig: float)
signal interacting(sig: float)
signal end_interact(sig: float)

enum InteractTypes {INSTANT, GRAB_ITEM, GRAB_OBJ, LEVER} # might move all the enums to a global class
@export var interaction_type : InteractTypes

@export var hand_prompt : String

func on_begin_interact() -> void:
	pass

func on_interacting() -> void:
	pass

func on_end_interact() -> void:
	pass
