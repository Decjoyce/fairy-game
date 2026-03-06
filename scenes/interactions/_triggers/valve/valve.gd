@icon("res://assets/_editor_icons/icon_valve.svg")
class_name Valve
extends Interactable

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export_category("Settings")
@export_range(0, 1.0, 0.05) var starting_value: float = 0.0

@onready var pivot: Node3D  = $Pivot
@onready var hand_pos: Node3D  = $Pivot/HandPos

var current_value: float = 0

var prev_angle: float = -1

func _ready() -> void:
	super()
	update_value(starting_value, false)

func update_value(amount: float, emit_sigs: bool = true) -> void:
	if disabled: return
	current_value = amount
	
	update_graphics()
	
	if !emit_sigs: return
	on_change.emit(current_value)
	if current_value >= 1.0:
		on_activated.emit(1.0)
	elif current_value <= 0:
		on_deactivated.emit(0.0)

func update_graphics() -> void:
	pivot.global_rotation_degrees.z = remap(current_value, 0, 1.0, -1080, 0)

func enable(sig: float = -1) -> void:
	visible = true
	$Trigger/_col.set_deferred("disabled", false)
	disabled = false

func disable(sig: float = -1) -> void:
	visible = false
	$Trigger/_col.set_deferred("disabled", true)
	disabled = true
