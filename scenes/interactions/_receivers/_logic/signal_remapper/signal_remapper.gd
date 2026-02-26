extends Node

signal remapped_sig(sig: float)

@export var new_min: float
@export var new_max: float

func remap_signal(sig: float) -> void:
	var new_sig: float = remap(sig, 0.0, 1.0, new_min, new_max)
	remapped_sig.emit(new_sig)
