@icon("res://assets/_editor_icons/icon_logic.svg")
extends Node

signal on_signal_converted(sig: bool)

func convert_to_bool(sig: float) -> void:
	on_signal_converted.emit(bool(sig))
