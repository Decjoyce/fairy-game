extends Node3D

##### SHOULD EVENTUALLY MAKE THIS UNIVERSAL FOR BOTH ITEMS AND PEEPS

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var trig_once: bool
@export var triggered: bool

func _player_entered(area: Area3D) -> void:
	if trig_once and triggered: return
	prints("TRIGGGGGGGGGGGGED")
	if area.get_parent() is PlayerTest:
		on_activated.emit(1.0)
		on_change.emit(0.0)
		triggered = true

func _player_exited(area: Area3D) -> void:
	if trig_once and triggered: return
	if area.get_parent() is PlayerTest:
		on_deactivated.emit(0.0)
		on_change.emit(0.0)
