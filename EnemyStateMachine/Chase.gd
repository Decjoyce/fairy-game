extends NodeState

@export var Body : StaticBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope
@export_category("A* Search")
@export var curr_tile: Vector3i = Vector3i(-2,0,24)
@export var goal_tile: Vector3i = Vector3i(4,0,0)
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
func on_process(delta : float):
	movement(delta)
	
func enter():
	grid_map =get_node("/root/GridMapPathfinding") 
	path = grid_map.find_path(curr_tile, goal_tile )
	#shmoove in derection of goal
	
	Animator.play("RESET")
	return path

func exit():
	Animator.stop()
	pass

func movement(delta: float) -> void:
	var i: int = 0
	points.resize(path.size())
	for next_point in path:
		target_pos.round() 
		target_pos.y = Body.global_position.y
		dist_to_target = Body.global_position.distance_to(target_pos)
		
		if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
			var weight = 1 - exp(-speed * delta)
			Body.global_position.x = lerpf(Body.global_position.x, target_pos.x, weight)
			Body.global_position.z = lerpf(Body.global_position.z, target_pos.z, weight)
			
			is_moving = true
		else:
			is_moving = false
			Body.global_position = target_pos 
			
		i += 1
			
		
