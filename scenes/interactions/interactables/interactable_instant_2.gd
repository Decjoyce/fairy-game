class_name InteractableInstant_2
extends Interactable

@export var interact_animation: String = "hand_press"

func begin_interact(sig: float = 1) -> void:
	on_begin_interact.emit(1.0)
