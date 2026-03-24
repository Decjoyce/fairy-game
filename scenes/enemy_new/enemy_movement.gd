class_name EnemyMovement
extends Node

@export var ballybog: Enemy_Ballybog_New

var grid_map: GridMapPathFinding 
var player: PlayerTest

enum MOVETYPES {NOT_MOVING, MOVING, TURNING, FALLING}
var current_move_type: MOVETYPES

@export var floor_detector: ImprovedRaycast

func _ready() -> void:
	grid_map = get_tree().get_first_node_in_group("GMPF")
	await get_parent().ready
	player = ballybog.player
	grid_map.setup_astar_grid(grid_map.walkable_items)

func update_idle(delta: float) -> void:
	pass
	
func update_physics(delta: float) -> void:
	movement(delta)
	turning(delta)


# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Destination Stuff ↓

var current_grid_pos: Vector3
var current_destination: Vector3
var current_path: Array
var rng := RandomNumberGenerator.new()

func set_new_destination(new_loc: Vector3) -> void:
	current_grid_pos = grid_map.astar.get_closest_position_in_segment(ballybog.global_position)
	current_destination = grid_map.astar.get_closest_position_in_segment(new_loc)
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	current_path.pop_front()
	has_reached_destination = false

func set_destination_to_player() -> void:
	current_grid_pos = grid_map.astar.get_closest_position_in_segment(ballybog.global_position)
	current_destination = grid_map.astar.get_closest_position_in_segment(ballybog.player.movement.target_pos)
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	#has_reached_destination = false
	#if current_path[0] == current_grid_pos:
	current_path.pop_front()

func get_random_destination(use_wander_point: bool = false) -> void:
	current_grid_pos = grid_map.astar.get_closest_position_in_segment(ballybog.global_position)
	var current_grid_pos_index: int
	if use_wander_point: current_grid_pos_index = grid_map.astar.get_closest_point(ballybog.wander_point)
	else: current_grid_pos_index = grid_map.astar.get_closest_point(ballybog.global_position)
	var neigbours = grid_map.astar.get_point_connections(current_grid_pos_index)
	var random_number = rng.randi_range(0, neigbours.size() -1)
	current_destination = grid_map.astar.get_point_position(neigbours[random_number])
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	current_path.pop_front()

func add_player_pos_to_destination() -> void:
	if current_path.size() <= 0:
		set_destination_to_player()
	else:
		var path_to_player := grid_map.find_path(current_path[current_path.size()-1],grid_map.astar.get_closest_position_in_segment(player.movement.target_pos))
		current_path.pop_back()
		#current_path.pop_front
		current_path.append_array(path_to_player)

func check_if_reached_destination() -> bool:
	return current_path.size() <= 0

func update_current_move_direction() -> void:
	current_move_direction = _start_pos.direction_to(_end_pos)

func stop_movement() -> void:
	is_moving = false
	has_reached_destination = false
	_time_started_moving = 0
	_time_started_turning = 0
	current_path.clear()

# ↑ Destination Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Moving Stuff ↓

@export var time_to_move: float = 500

var has_reached_destination: bool
var is_moving: bool
var _time_started_moving: float
var _start_pos: Vector3
var _end_pos: Vector3


signal on_reached_destination

func start_movement() -> void: ## probs should rename this to new movement
	if current_path.size() <= 0: return
	#print("-----------------")
	#print("Started_Movement")
	
	_start_pos = grid_map.astar.get_closest_position_in_segment(ballybog.global_position)
	_end_pos = current_path[0]
	#prints(_start_pos, _end_pos, current_destination)
	
	if check_if_needs_to_turn():
		start_turn()
	else:
		_begin_movement()

func _begin_movement() -> void:
	is_moving = true
	_time_started_moving = Time.get_ticks_msec()
	ballybog.anim_player.play("Walk2", -1, 2)
	current_move_type = MOVETYPES.MOVING

func movement(delta: float) -> void:
	if !is_moving or is_turning: return
	var time_since_start := Time.get_ticks_msec() - _time_started_moving
	var percentage_complete : = time_since_start / time_to_move
	
	var lerped_pos = lerp_me(_start_pos, _end_pos, percentage_complete)
	if floor_detector.is_colliding():
		lerped_pos.y = floor_detector.get_collision_point().y
	ballybog.global_position = lerped_pos
	
	if percentage_complete >= 1.0:
		complete_movement()

func complete_movement() -> void:
	is_moving = false
	current_path.pop_front()
	has_reached_destination = current_path.size() <= 0
	#print("Completed_Movement")
	#print("-----------------")
	if has_reached_destination:
		#print("REACHED DESTINATION")
		ballybog.do_idle()
		current_move_type = MOVETYPES.NOT_MOVING
		on_reached_destination.emit()
		current_path.clear()
		return
	start_movement()

# ↑ Moving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Turning Stuff ↓

@export var time_to_turn: float = 500

var current_move_direction: Vector3
var is_turning: bool
var _time_started_turning: float
var _start_rot: float
var _end_rot: float

signal has_turned

func check_if_needs_to_turn() -> bool:
	var prev_dir:= current_move_direction
	update_current_move_direction()
	return current_move_direction != prev_dir

func start_turn():
	#print("Started_Turning")
	#ballybog.do_idle()
	is_turning = true
	_time_started_turning = Time.get_ticks_msec()
	
	_start_rot = ballybog.graphics.global_rotation.y
	_end_rot = atan2(current_move_direction.x, current_move_direction.z)
	#prints(_start_rot, _end_rot)
	current_move_type = MOVETYPES.TURNING

func turning(delta: float) -> void:
	if !is_turning: return
	var time_since_start := Time.get_ticks_msec() - _time_started_turning
	var percentage_complete : = clampf(time_since_start / time_to_turn, 0.0, 1.0)
	
	var lerped_rot = lerp_angle(_start_rot, _end_rot, percentage_complete)
	ballybog.graphics.global_rotation.y = lerped_rot
	
	if percentage_complete >= 1.0:
		complete_turn()

func complete_turn() -> void:
	is_turning = false
	_start_rot = 0
	_end_rot = 0
	has_turned.emit()
	_begin_movement()
	#print("Completed_Turning")

# ↑ Moving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Turning Stuff ↓

func lerp_me(start: Vector3, end: Vector3, percentage: float) -> Vector3:
	var _percentage = clampf(percentage, 0.0, 1)
	var start_to_finish = end - start
	return (1-_percentage)*start + _percentage*end
