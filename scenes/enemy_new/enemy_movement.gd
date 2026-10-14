class_name EnemyMovement
extends Node

@export var ballybog: Enemy_Ballybog_New

var grid_map: GridMapPathFinding 
var player: PlayerTest

enum MOVETYPES {NOT_MOVING, MOVING, TURNING, FALLING}
var current_move_type: MOVETYPES

@export var floor_detector: ImprovedRaycast

func _ready() -> void:
	grid_map = ballybog.grid_map
	if grid_map == null:
		grid_map = get_tree().get_first_node_in_group("GMPF")
		if grid_map != null:
			push_warning("%s: grid_map nott set, using the level's GMPF grid" % ballybog.name)
	await get_parent().ready
	player = ballybog.player
	if grid_map == null:
		push_error("%s: no nav grid. Set grid_map on this Ballybog." % ballybog.name)
		return
	grid_map.ensure_astar_built()
	print("%s uses grid %s (%d cells)" % [ballybog.name, grid_map.get_path(), grid_map.astar.get_point_count()])

func update_idle(delta: float) -> void:
	pass
	
func update_physics(delta: float) -> void:
	move_particles.emitting = is_moving or is_turning
	movement(delta)
	turning(delta)


# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Destination Stuff ↓

var current_grid_pos: Vector3i
var current_destination: Vector3i
var current_path: Array
var rng := RandomNumberGenerator.new()

## World position -> nearest walkable cell on the nav grid.
## to_local undoes the grid node's offset and rotation
## get_closest_point snaps to a real cell,
## the old get_closest_position in segment could return a point between two cells,
## and Vector3i() then rounded it unpredictably
func world_to_cell(world_pos: Vector3) -> Vector3i:
	var local_pos: Vector3 = grid_map.to_local(world_pos) / grid_map.cell_size
	var point_id: int = grid_map.astar.get_closest_point(local_pos)
	if point_id == -1:
		push_error("%s: nav grid has no walkable cells" % ballybog.name)
		return Vector3i.ZERO
	return Vector3i(grid_map.astar.get_point_position(point_id))

## Nav Cell -> the world position the Ballybogs stands on for that cell.
## Gives the same result as (to_global(map_to_local(c).floor()) for these 1m grids,
## Walk targets don't move, so the existing nav point stays valid.
func cell_to_world(cell: Vector3i) -> Vector3:
	return grid_map.to_global(Vector3(cell) * grid_map.cell_size)
	
func set_new_destination(new_loc: Vector3) -> void:
	current_grid_pos = world_to_cell(ballybog.global_position)
	current_destination = world_to_cell(new_loc)
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	print("%s: path %s -> %s = %d cells" % [ballybog.name, current_grid_pos, current_destination, current_path.size()])
	current_path.pop_front()
	has_reached_destination = false
	#prints("-------------------------\n", grid_map.astar.get_closest_position_in_segment(ballybog.global_position), current_path)

func set_destination_to_player() -> void:
	current_grid_pos = world_to_cell(ballybog.global_position)
	current_destination = world_to_cell(player.movement.target_pos)
	#can_reach_destination()
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	#has_reached_destination = false
	#if current_path[0] == current_grid_pos:
	current_path.pop_front()

func get_random_destination(use_wander_point: bool = false) -> void:
	current_grid_pos = world_to_cell(ballybog.global_position)
	var anchor_cell: Vector3i = world_to_cell(ballybog.wander_point) if use_wander_point else current_grid_pos
	var neighbours = grid_map.astar.get_point_connections(grid_map.point_id_map[anchor_cell])
	var random_number = rng.randi_range(0, neighbours.size() -1)
	current_destination = Vector3i(grid_map.astar.get_point_position(neighbours[random_number]))
	current_path = grid_map.find_path(current_grid_pos,current_destination)
	current_path.pop_front()

func add_player_pos_to_destination() -> void:
	if current_path.size() <= 0:
		set_destination_to_player()
	else:
		var last_cell := Vector3i(current_path[current_path.size() -1])
		var path_to_player := grid_map.find_path(last_cell, world_to_cell(player.movement.target_pos))
		current_path.pop_back()
		current_path.append_array(path_to_player)
		

func check_if_reached_destination() -> bool:
	return current_path.size() <= 0

func update_current_move_direction() -> void:
	current_move_direction = (_start_pos * Vector3(1, 0, 1)).direction_to((_end_pos * Vector3(1, 0, 1)))

func can_reach_destination() -> bool:
	# is the player standing within one cell of a walkable cell
	var target: Vector3 = player.movement.target_pos
	var nearest: Vector3 = cell_to_world(world_to_cell(target))
	return absf(nearest.x - target.x) <= 1.0 and absf(nearest.z - target.z) <= 1.0

func stop_movement() -> void:
	is_moving = false
	has_reached_destination = false
	current_path.clear()

# ↑ Destination Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Moving Stuff ↓

@export var time_to_move: float = 500

var has_reached_destination: bool
var is_moving: bool
var _turn_elapsed: float
var _start_pos: Vector3
var _end_pos: Vector3

signal on_reached_destination
signal path_failed

func start_movement() -> void: ## probs should rename this to new movement
	if current_path.size() <= 0: 
		if current_grid_pos == current_destination:
			on_reached_destination.emit() # already standing on the target
		else:
			path_failed.emit() # no route to the target
		return
	#print("-----------------")
	#print("Started_Movement")
	
	_start_pos = ballybog.global_position #grid_map.astar.get_closest_position_in_segment(ballybog.global_position)
	_end_pos = cell_to_world(Vector3i(current_path[0]))
	
	# TEMP: every step should be exactly one cell
	var step_len := Vector2(_end_pos.x - _start_pos.x, _end_pos.z - _start_pos.z).length()
	if absf(step_len - 1.0) > 0.05:
		push_warning("%s: step of %.2f m from %s to %s" % [ballybog.name, step_len, _start_pos, _end_pos])
		
	if check_if_needs_to_turn():
		#print("turning")
		start_turn()
	else:
		#print("not turning")
		_begin_movement()

func _begin_movement() -> void:
	is_moving = true
	_move_elapsed = 0.0
	ballybog.anim_player.play("Walk2", -1, 2)
	current_move_type = MOVETYPES.MOVING

func movement(delta: float) -> void:
	if !is_moving or is_turning: return
	_move_elapsed += delta
	var percentage_complete := _move_elapsed / (time_to_move / 1000.0)
	
	var lerped_pos = lerp_me(_start_pos, _end_pos, percentage_complete)
	if floor_detector.is_colliding():
		lerped_pos.y = floor_detector.get_collision_point().y
	ballybog.global_position = lerped_pos
	
	
	if percentage_complete >= 1.0:
		imprint_footstep()
		complete_movement()

func complete_movement() -> void:
	is_moving = false
	current_path.pop_front()
	has_reached_destination = !current_path
	#print("Completed_Movement")
	#print("-----------------")
	if has_reached_destination:
		#prints("MOVEMOVEMOVE", "REACHED DESTINATION")
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
var _move_elapsed: float
var _start_rot: float
var _end_rot: float

signal has_turned

func check_if_needs_to_turn() -> bool:
	var prev_dir:= current_move_direction
	update_current_move_direction()
	#prints("dests: ", prev_dir, current_move_direction )
	return current_move_direction != prev_dir

func start_turn():
	#print("Started_Turning")
	#ballybog.do_idle()
	is_turning = true
	_turn_elapsed = 0.0
	
	_start_rot = ballybog.graphics.global_rotation.y
	_end_rot = atan2(current_move_direction.x, current_move_direction.z)
	#prints(_start_rot, _end_rot)
	current_move_type = MOVETYPES.TURNING

func turning(delta: float) -> void:
	if !is_turning: return
	_turn_elapsed += delta
	var percentage_complete := clampf(_turn_elapsed / (time_to_turn / 1000.0), 0.0, 1.0)
	
	var lerped_rot = lerp_angle(_start_rot, _end_rot, percentage_complete)
	ballybog.graphics.global_rotation.y = lerped_rot
	
	if percentage_complete >= 1.0:
		imprint_footstep()
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

# ↑ Turning Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ VFX Stuff ↓

@export var footstep_decals: Array[Decal]
var footstep_index: int
@export var move_particles: GPUParticles3D

func imprint_footstep() -> void:
	footstep_decals[footstep_index].visible = true
	footstep_decals[footstep_index].global_position = ballybog.global_position
	footstep_decals[footstep_index].global_rotation_degrees = ballybog.graphics.global_rotation_degrees + Vector3(0, 180, 0)
	footstep_index = wrapi(footstep_index+1, 0, footstep_decals.size())
