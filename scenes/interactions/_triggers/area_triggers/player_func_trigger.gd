extends Node3D

##### SHOULD EVENTUALLY MAKE THIS UNIVERSAL FOR BOTH ITEMS AND PEEPS

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var trig_once: bool
@export var triggered: bool

@export var func_to_call_on_enter: StringName
@export var func_to_call_on_exit: StringName

func _player_entered(area: Area3D) -> void:
	if trig_once and triggered: return
	if area.get_parent() is PlayerTest:
		area.get_parent().call(func_to_call_on_enter)
		on_activated.emit(1.0)
		on_change.emit(0.0)
		triggered = true

func _player_exited(area: Area3D) -> void:
	if trig_once and triggered: return
	if area.get_parent() is PlayerTest:
		area.get_parent().call(func_to_call_on_exit)
		on_deactivated.emit(0.0)
		on_change.emit(0.0)
