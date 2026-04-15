class_name BridgeNew
extends Node3D

@export var stay_open: bool
@export var speed: float
@export var speed_curve: Curve

@export_group("Angles")
@export var angle_to_toggle_barrier: float
@export var open_angle: float
@export var close_angle: float = 80
@onready var avp: AudioValuePlayer = $AudioValuePlayer

@export_group("IgnoreMe")
@export var col: StaticBody3D
@export var pivot: Node3D

@export_category("Override Signal Range")
@export var override_signal_range: bool = false
@export_range(0, 0.9, 0.01) var ovr_signal_min: float = 0
@export_range(0, 1.0, 0.01) var ovr_signal_max: float = 1.0

var is_opening: bool
var time_since_start: float = 0.0
var _start_angle: float
var _end_angle: float

var cur_value: float
var last_value: float

func _process(delta: float) -> void:
	if is_opening:
		time_since_start += delta
		var percentage_complete = clamp(time_since_start / speed, 0, 1)
		
		avp.play_me_bro(cur_value)
		
		pivot.rotation_degrees.z = bridge_lerp(_start_angle, _end_angle, percentage_complete)
		
		if percentage_complete >= 1:
			is_opening = false

func bridge_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish

func move_bridge(sig: float = -1) -> void:
	if stay_open and cur_value >= 1: return
	if override_signal_range: 
		if sig < ovr_signal_min: sig = ovr_signal_min
		elif sig > ovr_signal_max: sig = ovr_signal_max
		sig = remap(sig, ovr_signal_min, ovr_signal_max, 0, 1.0)
	
	begin_bridge_motion(sig)

func fully_open_bridge(sig: float = -1) -> void:
	begin_bridge_motion(1)

func close_bridge(sig: float = -1) -> void:
	begin_bridge_motion(0)

func begin_bridge_motion(percent: float) -> void:
	time_since_start = 0
	is_opening = true
	_start_angle = pivot.rotation_degrees.z
	last_value = cur_value
	cur_value = percent
	_end_angle = close_angle * (1 - percent)
	
	if _end_angle >= angle_to_toggle_barrier:
		col.set_collision_layer_value(1, true)
	else:
		col.set_collision_layer_value(1, false)

func toggle_gate(sig: float = -1) -> void:
	if cur_value > 0.5: close_bridge()
	else: fully_open_bridge()
