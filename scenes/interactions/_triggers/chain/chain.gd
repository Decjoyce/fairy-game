@icon("res://assets/_editor_icons/icon_chain.svg")
class_name Chain
extends Interactable

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export_category("Settings")
@export var debug_mode: bool

@export_category("Starting Value")
@export_range(0, 1.0, 0.05) var starting_value: float = 0.0
@export var emit_sig_when_using_start_value: bool = false

@export_category("Resetting When Not Used")
@export var slowly_reset_when_not_used: bool
@export var no_reset_if_activated: bool ## The chain will not reset if it is in the activated position
@export_range(0.1, 2.0, 0.1) var reset_speed: float = 1.0

@onready var graphics: Node3D = $temp_graphics
@onready var animated_object: AnimatedObject = $AnimatedObject
@onready var col: CollisionShape3D = $Trigger/_col
@onready var avp: AudioValuePlayer = $AudioValuePlayer

var point_end: Vector3
var point_top: Vector3

var current_value: float = 0

func _ready() -> void:
	super()
	update_value(starting_value, emit_sig_when_using_start_value, true)
	calc_top_n_end_points()
	if debug_mode: $Trigger/_debugmesh.visible = true
	else: $Trigger/_debugmesh.visible = false

func _process(delta: float) -> void:
	avp.play_me_bro(current_value)
	if !being_interacted_with and slowly_reset_when_not_used and current_value > 0:
		if no_reset_if_activated and current_value == 1.0: return
		slowly_reset_chain(delta)

func update_value(amount: float, emit_sigs: bool = true, override_disabled: bool = false) -> void:
	if !override_disabled and disabled: return
	current_value = amount
	
	update_graphics()
	
	if !emit_sigs: return
	on_change.emit(current_value)
	if current_value >= 1.0:
		on_activated.emit(1.0)
	elif current_value <= 0:
		on_deactivated.emit(0.0)

func slowly_reset_chain(_delta: float) -> void:
	var new_value = current_value - (reset_speed * _delta)
	update_value(new_value)
	if current_value < 0: current_value = 0


func calc_top_n_end_points() -> void:
	point_top = col.global_position + (Vector3.UP * col.shape.mid_height/2)
	point_end = col.global_position + (Vector3.UP * -col.shape.mid_height/2)
	$Trigger/_debugmesh/MeshInstance3D.global_position = point_top
	$Trigger/_debugmesh/MeshInstance3D2.global_position = point_end

# ↑ Calc Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Graphics Stuff ↓

func update_graphics() -> void:
	animated_object.play_animation(current_value)

# ↑ Graphics Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Enabling/Disabling Stuff ↓

func enable(sig: float = -1) -> void:
	visible = true
	$Trigger/_col.set_deferred("disabled", false)
	disabled = false

func disable(sig: float = -1) -> void:
	visible = false
	$Trigger/_col.set_deferred("disabled", true)
	disabled = true
