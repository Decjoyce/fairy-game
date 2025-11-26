extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope
@export_category("A* Search")
@export var curr_tile: Vector3i = Vector3i(3,0,-4)
@export var goal_tile: Vector3i = Vector3i(2,0, -6)
@export var player_tile: Vector3i = Vector3i(-2,0,18)
@onready var grid_map: GridMapPathFinding 
# Animator for what to play
# SM for state change
var is_moving: bool
var target_pos: Vector3
var speed: float = 4
var dist_to_target: float
var path := []
var points: PackedVector3Array
var curr_pos : int
var curr_posV : Vector3
var curr_posVi : Vector3i
var curr_posPlayerVi: Vector3i
var curr_posPlayerV: Vector3
var player : PlayerTest

var current_point: int
var target_node

func on_process(delta : float):
	#movement(delta)
	if Input.is_key_pressed(KEY_0): 
		get_pos()
		DebugPath()
		
func enter():
	grid_map =get_tree().get_first_node_in_group("GMPF")
	grid_map.setup_astar_grid(grid_map.walkable_items)
	prints(grid_map.walkable_items)
	player = get_tree().get_first_node_in_group("Player")
	Animator.play("RESET")
	return path

func exit():
	Animator.stop()
	pass
	
func get_pos():
	curr_posVi = Body.position
	curr_posPlayerVi = player.position
	curr_posPlayerV = grid_map.astar.get_closest_position_in_segment(player.position)      #Vector3(player.position.x,0,player.position.z)
	curr_posV = Body.position
	curr_pos = grid_map.astar.get_closest_point(Body.position)
	curr_posV = grid_map.astar.get_closest_position_in_segment(Body.position)
	path = grid_map.find_path(curr_posV,curr_posPlayerV)
	print(curr_posV, curr_posPlayerV, curr_posVi, curr_posPlayerVi)
	prints(path)
	pass

func movement(delta: float) -> void:
	
	prints(current_point, path.size())
	if current_point < path.size():
		is_moving = true
		target_pos.round() 
		target_pos.y = Body.global_position.y
		dist_to_target = Body.global_position.distance_to(target_pos)
		
		if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
			var weight = 1 - exp(-speed * delta)
			Body.global_position.x = lerpf(Body.global_position.x, target_pos.x, weight)
			Body.global_position.z = lerpf(Body.global_position.z, target_pos.z, weight)
		else:
			get_next_target()
			Body.global_position = target_pos
	else:
		is_moving = false
		SM.transition_to("Fighting")
	

func get_next_target() -> void:
	current_point+=1
	target_pos = path[current_point]

func DebugPath():
	grid_map.do_debug_path(curr_posV,curr_posPlayerV)
	
	pass
