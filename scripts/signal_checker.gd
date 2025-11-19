extends Node

func activated(sig: float) -> void:
	prints("Signal Activated: ", sig)

func changed(sig: float) -> void:
	prints("Signal Changed: ", sig)

func deactivated(sig: float) -> void:
	prints("Signal Deactivated: ", sig)
