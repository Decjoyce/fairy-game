class_name MovementImproved2
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
var max_unit_move: float = 5 # is max amount of spaces to lerp to in one go

var percentage_complete: float # how close to completing the move

func add_move_amount_vertical(_z_amount: float) -> void:
	target_z = clampf(target_z + _z_amount, -max_unit_move, max_unit_move)
	match current_dir:
		MovementDirections.STATIONARY:
			current_dir = MovementDirections.VERTICAL
			begin_moving()
		MovementDirections.VERTICAL:
			_end_position = clampf(_end_position + target_z, _start_position - max_unit_move, _start_position+max_unit_move)
		MovementDirections.HORIZONTAL: 
			is_changing_dir = true

func add_move_amount_horizontal(_x_amount: float) -> void:
	target_x = clamp(target_x + _x_amount, - max_unit_move, max_unit_move)
	match current_dir:
		MovementDirections.STATIONARY:
			current_dir = MovementDirections.HORIZONTAL
			begin_moving()
		MovementDirections.HORIZONTAL:
			_end_position = clampf(_end_position + target_x, _start_position - max_unit_move, _start_position+max_unit_move)
		MovementDirections.VERTICAL: 
			is_changing_dir = true

func begin_moving() -> void:
	is_moving = true
	time_move_started = Time.get_ticks_msec()
	percentage_complete = 0.0
	_start_position = 0
	_end_position = 0
	
	print("r")
	
	match current_dir:
		MovementDirections.VERTICAL: 
			_start_position = parent.global_position.z
			print(target_z)
			_end_position = parent.global_position.round().z + target_z
		MovementDirections.HORIZONTAL: 
			_start_position = parent.global_position.x
			print(target_x)
			_end_position = parent.global_position.round().x + target_x


func movement_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish

func move(speed: float, delta: float) -> void:
	if is_moving:
		var time_since_start := Time.get_ticks_msec() - time_move_started
		var length_to_complete = abs(_end_position - _start_position) / speed
		percentage_complete = time_since_start / length_to_complete
		
		match current_dir:
			MovementDirections.VERTICAL: 
				parent.global_position.z = movement_lerp(_start_position, _end_position, percentage_complete)
			MovementDirections.HORIZONTAL: 
				parent.global_position.x = movement_lerp(_start_position, _end_position, percentage_complete)
		
		movement_checker()

var temp_bool: bool

func movement_checker() -> void:
	if !check_if_on_grid():
		temp_bool = false
		return
	if !temp_bool and percentage_complete > 0:
		#print("g")
		temp_bool = true
		if is_changing_dir:
			var move_dir := _end_position - _start_position
			var rounded_pos: Vector3
			if move_dir > 0: rounded_pos = parent.global_position.ceil()
			elif move_dir < 0: rounded_pos = parent.global_position.floor()
			
			match current_dir:
				MovementDirections.VERTICAL: 
					current_dir = MovementDirections.HORIZONTAL
					parent.global_position.z = rounded_pos.z
					target_z = 0
				MovementDirections.HORIZONTAL: 
					current_dir = MovementDirections.VERTICAL
					parent.global_position.x = rounded_pos.x
					target_x = 0
			is_changing_dir = false
			begin_moving()
			
		elif percentage_complete >= 1.0: # player has reached their goal
			#print("hey")
			is_moving = false
			percentage_complete = 0
			#_start_position = 0
			#_end_position = 0
			target_z = 0
			target_x = 0
			current_dir = MovementDirections.STATIONARY
		else:
			if current_dir == MovementDirections.VERTICAL: 
				if target_z > 0: target_z  -= 1
				elif target_z < 0: target_z += 1
			elif current_dir == MovementDirections.HORIZONTAL: 
				if target_x > 0: target_x  -= 1
				elif target_x < 0: target_x += 1
	elif check_if_on_grid():
		#print("e")
		temp_bool = false

func check_if_on_grid() -> bool:
	var move_dir := _end_position - _start_position
	var dist_to_grid_floored = parent.global_position.distance_to(parent.global_position.floor())
	var dist_to_grid_ceiled = parent.global_position.distance_to(parent.global_position.ceil())
	if move_dir < 0 and dist_to_grid_floored >= -0.01 and dist_to_grid_floored <= 0.01:
		return true
	elif move_dir > 0 and  dist_to_grid_ceiled >= -0.01 and dist_to_grid_ceiled <= 0.01:
		return true
	else:
		return false
