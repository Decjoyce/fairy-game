extends Node3D

##### SHOULD EVENTUALLY MAKE THIS UNIVERSAL FOR BOTH ITEMS AND PEEPS

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var trig_once: bool
@export var override_signal: float = -1

var trigged: bool

func _player_entered(area: Area3D) -> void:
	if trig_once and trigged: return
	print("loplp")
	if area.get_parent() is PlayerTest:
		if override_signal >= 0: on_activated.emit(override_signal)
		else: on_activated.emit(1.0)
		on_change.emit(0.0)
		trigged = true

func _player_exited(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		on_deactivated.emit(0.0)
		on_change.emit(0.0)
