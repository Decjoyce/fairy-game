class_name Interactable
extends Node3D

signal on_begin_interact(sig: float)
signal on_interacting(sig: float)
signal on_end_interact(sig: float)

enum InteractTypes {INSTANT, GRAB_ITEM, GRAB_OBJ, LEVER, TEMP_ATTACK} # might move all the enums to a global class
@export var interaction_type : InteractTypes

@export var hand_prompt : String = "hand_prompt_default"
@export var prompt_text: String = ""

@export var disabled: bool

func begin_interact(sig: float = -1) -> void:
	pass

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	pass

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Enabling Stuff ↓

func enable() -> void:
	pass

func disable() -> void:
	pass

# ↑ Enabling Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Saving Stuff ↓

func on_save_game(saved_data: Array[SavedData]) -> void:
	pass

func on_before_load_game() -> void:
	pass

func on_load_game(saved_data: SavedData) -> void:
	pass
