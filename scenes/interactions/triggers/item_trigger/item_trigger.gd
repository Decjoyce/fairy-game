extends Area3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var do_once: bool
@export var specific_item: Grabbable_Item
@export var delete_obj_after_use: bool

var activated: bool

func _on_item_entered(body: Node3D) -> void:
	if do_once and activated: return
	if body is Grabbable_Item:
		if specific_item and body == specific_item:
			activate()
			if delete_obj_after_use:
				body.queue_free()


func _on_item_exited(body: Node3D) -> void:
	if do_once and activated: return
	if body is Grabbable_Item:
		if specific_item and body == specific_item:
			deactivate()

func activate() -> void:
	if do_once and activated: return
	on_change.emit(1.0)
	on_activated.emit(1.0)
	activated = true

func deactivate() -> void:
	if do_once and activated: return
	on_change.emit(0)
	on_deactivated.emit(0)
	activated = false
