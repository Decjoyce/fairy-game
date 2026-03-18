@icon("res://assets/_editor_icons/icon_lever.svg")
class_name Lever
extends Interactable

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export_category("Settings")
@export_range(0, 1.0, 0.05) var starting_value: float = 0.0
@export var emit_sig_when_using_start_value: bool

@export_category("Intervals")
@export var use_intervals: bool = false
@export_range(0, 1.0, 0.05) var intervals: float = 0.2

var current_value: float = 0
@onready var pivot: Node3D = %Pivot
@onready var hand_pos_top: Node3D = %pos_top
@onready var hand_pos_mid: Node3D = %pos_middle
@onready var hand_pos_bottom: Node3D = %pos_bottom

func _ready() -> void:
	super()
	update_value(starting_value, emit_sig_when_using_start_value, true)

func begin_interact(sig: float = -1) -> void:
	pass

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	pass

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Calc Stuff ↓

func update_value(amount: float, emit_sigs: bool = true, override_disabled: bool = false) -> void:
	if !override_disabled and disabled: return
	current_value = amount
	
	if use_intervals: 
		current_value = snappedf(current_value, intervals)
		#print(current_value)
	
	update_graphics()
	if emit_sigs:
		on_change.emit(current_value)
		if current_value >= 1.0:
			on_activated.emit(1.0)
		elif current_value <= 0:
			on_deactivated.emit(0.0)
		

# ↑ Calc Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

func update_graphics() -> void:
	var new_rot: float = remap(current_value, 0, 1.0, -45, 45)
	pivot.rotation_degrees.x = new_rot

# ↑ Graphics Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Other Stuff ↓

func change_interval_value(sig: float) -> void:
	intervals = sig
	update_value(current_value)

# ↑ Other Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Enabling/Disabling Stuff ↓

func enable(sig: float = -1) -> void:
	#print("Fiddlesticks")
	visible = true
	$Trigger/CollisionShape3D.set_deferred("disabled", false)
	disabled = false

func disable(sig: float = -1) -> void:
	visible = false
	$Trigger/CollisionShape3D.set_deferred("disabled", true)
	disabled = true
