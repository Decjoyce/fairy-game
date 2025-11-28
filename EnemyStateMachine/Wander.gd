extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope

@onready var grid_map: GridMapPathFinding 
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
var curr_posVi : int
var curr_TargetPoint: Vector3
var player : PlayerTest
var inVision : bool
var current_point: int
var rng = RandomNumberGenerator.new()



func on_physics_process(delta: float) -> void:
		if path.size() >= 1:
			moveW(delta)
			if Animator.current_animation != "test_walk":
				Animator.play("test_walk")
		else: Animator.play("Idle")
			
			  

func on_process(delta : float):

	
	
	pass
func enter():
	grid_map =get_tree().get_first_node_in_group("GMPF")
	grid_map.setup_astar_grid(grid_map.walkable_items)
	prints(grid_map.walkable_items)
	player = get_tree().get_first_node_in_group("Player")
	Animator.play("RESET")
	
	RandomWander()

	return path


func RandomWander():
	
	curr_posV = grid_map.astar.get_closest_position_in_segment(Body.global_position)
	curr_posVi = grid_map.astar.get_closest_point(Body.global_position)
	var neigbours = grid_map.astar.get_point_connections(curr_posVi)
	var random_number = rng.randf_range(0, neigbours.size())
	curr_TargetPoint = grid_map.astar.get_point_position(neigbours.get(random_number))
	path = grid_map.find_path(curr_posV,curr_TargetPoint)
	prints(path)
	prints(neigbours)
	$Timer.start(8)
		
	##print(curr_posV, curr_posPlayerV, curr_posVi, curr_posPlayerVi)
	pass

func moveW(delta: float) -> void:
	if path.size()<= 0:
		return
	target_pos = path[0]
	prints(current_point, path.size())
	if current_point < path.size():
		is_moving = true
		
		target_pos.y = Body.global_position.y
		dist_to_target = Body.global_position.distance_to(target_pos)
		
		if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
			#var weight = 1 - exp(-speed * delta)
			var direction = Body.global_position.direction_to(target_pos)
			#Body.velocity = direction * speed 
			#Body.move_and_slide()
			Body.look_at(target_pos)
			Body.global_position.x = lerpf(Body.global_position.x, target_pos.x, speed * delta)
			Body.global_position.z = lerpf(Body.global_position.z, target_pos.z, speed * delta)
			
		else:
			Body.velocity = Vector3(0,0,0)
			get_next_target()
			#Body.global_position = target_pos
	else:
		is_moving = false
		#SM.transition_to("Fighting")
	

func get_next_target() -> void:
	if path.size() <= 0:
		return 
	path.pop_front()
	if path.size() <= 0:
		return 
	target_pos = path[0]
	Animator.play("test_walk")
	

func exit():
	Animator.stop()
	$Timer.stop()
	pass


func _on_timer_timeout() -> void:
	RandomWander()
	Animator.play("test_walk")
	pass # Replace with function body.


func _on_area_3d_2_area_entered(area: Area3D) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Chase")
	pass # Replace with function body.

func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Fighting")
