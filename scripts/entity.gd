@icon("res://assets/_editor_icons/icon_ballyhead.svg")
class_name Entity
extends Node3D

@onready var stats: Stats = $Stats

var current_weight: float
var current_pressureplate: PressurePlate # Temp

func die() -> void:
	pass
