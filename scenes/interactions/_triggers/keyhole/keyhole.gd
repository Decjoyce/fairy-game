class_name Keyhole
extends Interactable

var current_value: float = 0.0

signal on_activated(sig: float)

@export_category("Intervals")
@export var use_intervals: bool = false
@export_range(0, 1.0, 0.05) var intervals: float = 0.2

@onready var hand_pos: Node3D = $hand_pos
@onready var col: CollisionShape3D = $Area3D/CollisionShape3D

var activated: bool

func activate() -> void:
	if activated: return
	activated = true
	on_activated.emit(1.0)
	col.set_deferred("disabled", true)

#func update_value(amount: float) -> void:
	#if disabled: return
	#current_value = amount
	#
	#if use_intervals: 
		#current_value = snappedf(current_value, intervals)
		#print(current_value)
	#
	#on_change.emit(current_value)
	#if current_value >= 1.0:
		#on_activated.emit(1.0)
		#disabled = true
	#elif current_value <= 0:
		#on_deactivated.emit(0.0)
