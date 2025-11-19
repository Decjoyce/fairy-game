extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

var is_opening: bool
var time_move_started: float 
var _start_position: float
var _end_position: float
var closed_pos: float = 2
@export var speed: float = 100
@onready var graphics: Node3D = $gate

func open_gate(amount: float) -> void:
	time_move_started = Time.get_ticks_msec()
	is_opening = true
	_start_position = graphics.position.y
	prints("open: ", amount)
	_end_position = 1 + (closed_pos * amount)

func _process(delta: float) -> void:
	if is_opening:
		var time_since_start := Time.get_ticks_msec() - time_move_started
		var percentage_complete = clamp(time_since_start / speed, 0, 1)
		#prints(length_to_complete, percentage_complete)
		
		graphics.position.y = plate_lerp(_start_position, _end_position, percentage_complete)
		
		if percentage_complete >= 1:
			is_opening = false

func plate_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish
