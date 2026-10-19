extends Area3D

##### SHOULD EVENTUALLY MAKE THIS UNIVERSAL FOR BOTH ITEMS AND PEEPS

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var trig_once: bool
var triggered: bool

func _itm_entered(body: Node3D) -> void:
	if trig_once: return
	if body is Grabbable_Item:
		on_activated.emit(1.0)
		on_change.emit(0.0)
		triggered = true

func _itm_exited(body: Node3D) -> void:
	if body.get_parent() is Grabbable_Item:
		on_deactivated.emit(0.0)
		on_change.emit(0.0)

func reset_trigger(_sig: float = -1) -> void:
	triggered = false
