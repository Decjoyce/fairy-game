class_name LevelSequencer
extends Node

@export var seq_to_set: int 

func set_seq_via_sig(sig: float = -1) -> void:
	TEMPSaveGameHandler.current_seq = seq_to_set
