extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope
@export_category("A* Search")
@export var curr_tile: Vector3i = Vector3i(3,0,-4)
@export var goal_tile: Vector3i = Vector3i(2,0, -6)
@export var player_tile: Vector3i = Vector3i(-2,0,18)
@onready var grid_map: GridMapPathFinding 
@export var footstep_audio: AudioStreamPlayer3D
@export var Debug_draw: bool

# Animator for what to play
# SM for state change
var is_moving: bool
var target_pos: Vector3
@export var speed: float = 4
var dist_to_target: float
var path := []
var points: PackedVector3Array
var curr_pos : int
var curr_posV : Vector3
var curr_posPlayerV: Vector3
var player : PlayerTest
var inVision : bool
var current_point: int



func on_physics_process(delta: float) -> void:
		movement(delta)

func on_process(delta : float):
	#movement(delta)
	#get_pos()
	if Debug_draw :
		if Input.is_key_pressed(KEY_0): 
			get_pos()
			find_path()
		DebugPath()

		
func enter():
	grid_map =get_tree().get_first_node_in_group("GMPF")
	grid_map.setup_astar_grid(grid_map.walkable_items)
	prints(grid_map.walkable_items)
	player = get_tree().get_first_node_in_group("Player")
	Animator.play("Walk2",-1,0.5)
	get_pos()
	find_path()
	return path

func exit():
	Animator.stop()
	$Timer.stop()
	pass
	
func get_pos():
	#curr_posVi = Body.global_position
	#curr_posPlayerVi = player.global_position
	curr_posPlayerV = grid_map.astar.get_closest_position_in_segment(player.get_child(1).global_position)      #Vector3(player.position.x,0,player.position.z)
	#curr_pos = grid_map.astar.get_closest_point(Body.global_position)
	curr_posV = grid_map.astar.get_closest_position_in_segment(Body.global_position)
	prints(curr_posV, curr_posPlayerV,)
	##path = grid_map.find_path(curr_posV,curr_posPlayerV)
	pass
	
func find_path():
	path = grid_map.find_path(curr_posV,curr_posPlayerV)
	##print(curr_posV, curr_posPlayerV, curr_posVi, curr_posPlayerVi)
	prints(path)
	pass

func debug_move():
	Body.position = path[path.size()-1]

	pass

func movement(delta: float) -> void:
	if path.size()<= 0:
		return
	target_pos = path[0]
	prints(current_point, path.size())
	if current_point < path.size():
		is_moving = true
		footstep_audio.play()
		target_pos.y = Body.global_position.y
		dist_to_target = Body.global_position.distance_to(target_pos)
		
		if dist_to_target > 0.01: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
			#var weight = 1 - exp(-speed * delta)
			Body.look_at(target_pos)
			Body.global_position.x = lerpf(Body.global_position.x, target_pos.x, speed * delta)
			Body.global_position.z = lerpf(Body.global_position.z, target_pos.z, speed * delta)
		else:
			get_next_target()
			#Body.global_position = target_pos
	else:
		is_moving = false
		SM.transition_to("Fighting")
	

func get_next_target() -> void:
	if path.size() <= 0:
		return 
	path.pop_front()
	if path.size() <= 0:
		return 
	target_pos = path[0]
	$Timer.start()
	

func DebugPath():
	grid_map.do_debug_path(curr_posPlayerV,curr_posV)
	
	pass

############## GET THE FIGHT MODE TRANSFER TO STATE HERE############
# if entered area 3d most likely or the distance to player is >= to something

##func _on_area_3d_2_area_entered(area: Area3D) -> void:
	
	
	#print(area)
	## The direction to the player body.
	#var direction = Body.global_position.direction_to(area.global_position)
	## The location normalized of where the player is in relation to the front
	## of the enemy
	#var facing = Body.global_transform.basis.tdotz(direction)
	#var fov = cos(deg_to_rad(70))
	#print(facing)
	#print(fov)
	#if (area.is_in_group("Player")):
		#if facing > fov:
			#inVision = true
			#print("FOV:YES,HEAR:YES")
		#else:
			#inVision = false
			#print("FOV:NO,HEAR:YES")
	#
		


func _on_area_3d_2_area_exited(area: Area3D) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Wander")
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	get_pos()
	find_path()
	$Timer.start()
	


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Fighting")
