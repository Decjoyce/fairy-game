class_name MovementImproved
extends Node

@onready var parent: Node3D = get_parent()

var is_moving: bool
var moving_vertically: bool
var moving_horizontally: bool
var is_changing_dir: bool

#var target_x: float
#var target_z: float
var target_position: Vector3
var max_unit_move = 3

var grid_check_offset: float = 0.005
var base_grid_check_offset: float = 0.005
var changing_dir_grid_check_offset: float = 0.01

var movement_curve: Curve3D

##TO DO: REDO THIS
func add_position_marker_vertical(_z_amount: float) -> void:
#	target_z = clamp(target_z + _z_amount, -max_unit_move, max_unit_move)
	if moving_horizontally: # when player is moving different dir 
		is_changing_dir = true
		target_position.z = round(parent.global_position.z) + _z_amount
		grid_check_offset = changing_dir_grid_check_offset
	elif !moving_vertically and !is_changing_dir: # when player hasn't moved
		moving_vertically = true
		is_moving = true
		target_position.z = round(parent.global_position.z) + _z_amount
		grid_check_offset = base_grid_check_offset
	elif !is_changing_dir: # when player is moving in same dir
		is_moving = true
		grid_check_offset = base_grid_check_offset
		target_position.z += _z_amount

func add_position_marker_horizontal(_x_amount: float) -> void:
#	target_x = clamp(target_x + _x_amount, -max_unit_move, max_unit_move)
	if moving_vertically:
		is_changing_dir = true
		target_position.x = round(parent.global_position.x) + _x_amount
		grid_check_offset = changing_dir_grid_check_offset
	elif !moving_horizontally and !is_changing_dir: # when player hasn't moved
		moving_horizontally = true
		is_moving = true
		grid_check_offset = base_grid_check_offset
		target_position.x = round(parent.global_position.x) + _x_amount
	elif !is_changing_dir: # when player is moving in same dir
		target_position.x += _x_amount
		grid_check_offset = base_grid_check_offset
		is_moving = true

func move(speed: float, delta: float) -> void:
	target_position.rotated(Vector3.UP, parent.rotation.y)
	if is_moving:
		movement_checker()
		var weight := 1 - exp(-speed * delta)
		var better_weight := (1 - cos(PI * weight)) / 2
		if moving_vertically:
			parent.global_position.z = lerpf(parent.global_position.z, target_position.z, better_weight)
		elif moving_horizontally:
			parent.global_position.x = lerpf(parent.global_position.x, target_position.x, better_weight)
	
	
func movement_checker() -> void:
	target_position.y = parent.global_position.y
	if check_if_on_grid():
		#print("yo")
		if is_changing_dir:
			if moving_vertically: parent.global_position.z = target_position.z
			if moving_horizontally: parent.global_position.x = target_position.x
			
			moving_vertically = !moving_vertically
			moving_horizontally = !moving_horizontally
			
			#if moving_horizontally: target_position.x = round(parent.global_position.x) + target_z
			
			is_changing_dir = false
			
		else:
			if moving_vertically and check_if_reached_target_z():
				parent.global_position.z = target_position.z
				moving_vertically = false
				is_moving = false
			if moving_horizontally and check_if_reached_target_x():
				parent.global_position.x = target_position.x
				moving_horizontally = false
				is_moving = false

var dist_floored: Vector3
var dist_to_grid_floored: float
var dist_ceiled: Vector3
var dist_to_grid_ceiled: float

var grid_checker: bool
var checker_x: bool
var checker_z: bool

func check_if_on_grid() -> bool:
	dist_floored = parent.global_position.floor()
	dist_to_grid_floored = parent.global_position.distance_to(Vector3(dist_floored.x, parent.global_position.y, dist_floored.z))
	dist_ceiled = parent.global_position.ceil()
	dist_to_grid_ceiled = parent.global_position.distance_to(Vector3(dist_ceiled.x, parent.global_position.y, dist_ceiled.z))
	if dist_to_grid_floored >= -grid_check_offset and dist_to_grid_floored <= grid_check_offset:
		grid_checker = true
		return true
	elif dist_to_grid_ceiled >= -grid_check_offset and dist_to_grid_ceiled <= grid_check_offset: 
		grid_checker = true
		return true
	else:
		grid_checker = false
		return false

func check_if_reached_target_z() -> bool:
	var dist_to_target = abs(parent.global_position.z - target_position.z)
	#print(dist_to_target)
	if dist_to_target >= -grid_check_offset and dist_to_target <= grid_check_offset:
		checker_z = true
		return true
	else:
		checker_z = false
		return false

func check_if_reached_target_x() -> bool:
	var dist_to_target = abs(parent.global_position.x - target_position.x)
	#print(dist_to_target)
	if dist_to_target >= -grid_check_offset and dist_to_target <= grid_check_offset:
		checker_x = true
		return true
	else:
		checker_x = false
		return false
