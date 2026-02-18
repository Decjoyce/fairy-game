@icon("res://assets/_editor_icons/icon_logic.svg")
extends Node

signal on_activated(sig: bool)
signal on_deactivated(sig: bool)

func convert_to_bool(sig: float) -> void:
	on_activated.emit(bool(sig))
