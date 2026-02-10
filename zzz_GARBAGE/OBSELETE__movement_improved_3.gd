class_name MovementImproved3
extends Node

@onready var parent: Node3D = get_parent()

enum MovementDirections {STATIONARY, VERTICAL, HORIZONTAL}
var is_moving: bool
var current_dir: MovementDirections 
var is_changing_dir: bool

var time_move_started: float # 
var _start_position: float
var _end_position: float

var target_z: float # is how many spaces to move (how many times you've inputed)
var target_x: float
var max_unit_move: float = 3 # is max amount of spaces to lerp to in one go

var percentage_complete: float # how close to completing the move

func add_move_amount_vertical(_z_amount: float) -> void:
	target_z = clamp(target_z + _z_amount, -max_unit_move, max_unit_move)
	match current_dir:
		MovementDirections.STATIONARY:
			current_dir = MovementDirections.VERTICAL
			begin_moving()
		MovementDirections.VERTICAL:
			_end_position += target_z
		MovementDirections.HORIZONTAL: 
			is_changing_dir = true

func add_move_amount_horizontal(_x_amount: float) -> void:
	target_x = clamp(target_x + _x_amount, - max_unit_move, max_unit_move)
	match current_dir:
		MovementDirections.STATIONARY:
			current_dir = MovementDirections.HORIZONTAL
			begin_moving()
		MovementDirections.HORIZONTAL:
			_end_position += target_x
		MovementDirections.VERTICAL: 
			is_changing_dir = true

func begin_moving() -> void:
	is_moving = true
	time_move_started = Time.get_ticks_msec()
	percentage_complete = 0.0
	
	match current_dir:
		MovementDirections.VERTICAL: 
			_start_position = parent.global_position.z
			_end_position = parent.global_position.round().z + target_z
		MovementDirections.HORIZONTAL: 
			_start_position = parent.global_position.x
			_end_position = parent.global_position.round().x + target_x	


func movement_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish

func move(speed: float, delta: float) -> void:
	if is_moving:
		var time_since_start := Time.get_ticks_msec() - time_move_started
		var length_to_complete = target_z / speed
		percentage_complete = time_since_start / speed
		
		match current_dir:
			MovementDirections.VERTICAL: 
				parent.global_position.z = movement_lerp(_start_position, _end_position, percentage_complete)
			MovementDirections.HORIZONTAL: 
				parent.global_position.x = movement_lerp(_start_position, _end_position, percentage_complete)
		
		movement_checker()

func movement_checker() -> void:
	if check_if_on_grid():
		if target_z > 0: target_z  -= 1
		elif target_z < 0: target_z += 1
		
		if target_x > 0: target_x  -= 1
		elif target_x < 0: target_x += 1
		
		if is_changing_dir:
			if current_dir == MovementDirections.VERTICAL: 
				current_dir = MovementDirections.HORIZONTAL
				target_z = 0
			elif current_dir == MovementDirections.HORIZONTAL: 
				current_dir = MovementDirections.VERTICAL
				target_x = 0
			
			begin_moving()
			
		elif percentage_complete >= 1.0: # player has reached their goal
			is_moving = false
			percentage_complete = 0
			target_z = 0
			target_x = 0
			current_dir = MovementDirections.STATIONARY

func check_if_on_grid() -> bool:
	var dist_to_grid_floored = parent.global_position.distance_to(parent.global_position.floor())
	var dist_to_grid_ceiled = parent.global_position.distance_to(parent.global_position.ceil())
	if dist_to_grid_floored >= -0.01 or dist_to_grid_floored <= 0.01:
		return true
	elif dist_to_grid_ceiled >= -0.01 or dist_to_grid_ceiled <= 0.01:
		return true
	else:
		return false
