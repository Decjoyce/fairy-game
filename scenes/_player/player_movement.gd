class_name PlayerMovement
extends Node

@export var player: Node3D
@export var interact: PlayerInteract

@onready var compass: Node3D = $Compass

@onready var ray_north: ShapeCast3D = $Compass/North ## Checks if player can move forward and also temporary interact
@onready var ray_east: ShapeCast3D = $Compass/East ## Checks if player can move right
@onready var ray_south: ShapeCast3D = $Compass/South ## Checks if player can move back
@onready var ray_west: ShapeCast3D = $Compass/West ## Checks if player can move left
@export var floor_detector: RayCast3D ## Checks if player can move left

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Movin Stuff ↓

var is_moving: bool
var target_pos: Vector3
var speed: float = 4
var dist_to_target: float

enum MoveDirections {NOT_MOVING, VERTICAL, HORIZONTAL}
var current_direction: MoveDirections

signal on_move(direction: Vector2, target_position: Vector3)
signal on_move_up(target_position: Vector3)
signal on_move_down(target_position: Vector3)
signal on_move_left(target_position: Vector3)
signal on_move_right(target_position: Vector3)

func _ready() -> void:
	compass.global_position = player.global_position

func movement_input() -> void:
	
	if Input.is_action_just_pressed("move_up") and check_can_move_up():
		target_pos = target_pos - compass.basis.z * Vector3.ONE
		
		current_direction = MoveDirections.VERTICAL
		on_move.emit(Vector3.FORWARD, target_pos)
		
		on_move_up.emit(target_pos)
	elif Input.is_action_just_pressed("move_down") and check_can_move_down():
		target_pos = target_pos + compass.basis.z * Vector3.ONE
		
		current_direction = MoveDirections.VERTICAL
		
		on_move.emit(Vector3.BACK, target_pos)
		on_move_down.emit(target_pos)
	elif Input.is_action_just_pressed("move_left") and check_can_move_left():
		target_pos = target_pos - compass.basis.x * Vector3.ONE
		
		current_direction = MoveDirections.HORIZONTAL
		
		on_move.emit(Vector3.LEFT, target_pos)
		on_move_left.emit(target_pos)
	elif Input.is_action_just_pressed("move_right") and check_can_move_right():
		target_pos = target_pos + compass.basis.x * Vector3.ONE
		
		current_direction = MoveDirections.HORIZONTAL
		
		on_move.emit(Vector3.RIGHT, target_pos)
		on_move_right.emit(target_pos)
	
	target_pos.round() 
	target_pos.y = player.global_position.y
	compass.global_position = target_pos

func movement(delta: float) -> void:
	target_pos.round() 
	target_pos.y = player.global_position.y
	dist_to_target = player.global_position.distance_to(target_pos)
	
	if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
		#t_bob += delta * (target_pos - player.position).length() * speed ## some headbobbing formula i used before. Its really bad.
		var weight = 1 - exp(-speed * delta)
		player.global_position.x = lerpf(player.global_position.x, target_pos.x, weight)
		player.global_position.z = lerpf(player.global_position.z, target_pos.z, weight)
		
		if floor_detector.get_collision_point():
			player.global_position.y = floor_detector.get_collision_point().y + player.PLAYER_HEIGHT
		
		is_moving = true
	else:
		is_moving = false
		player.global_position = target_pos 

func check_can_move_up() -> bool:
	#if DEBUG.noclip: return true
	if check_grabbed_obj_direction(0): 
		print("j")
		return false
	return !ray_north.is_colliding() and (dist_to_target <= 0.6 or current_direction != MoveDirections.HORIZONTAL)

func check_can_move_down() -> bool:
	#if DEBUG.noclip: return true
	if check_grabbed_obj_direction(1): return false
	return !ray_south.is_colliding() and (dist_to_target <= 0.6 or current_direction != MoveDirections.HORIZONTAL)

func check_can_move_left() -> bool:
	#if DEBUG.noclip: return true
	if check_grabbed_obj_direction(2): return false
	return !ray_west.is_colliding() and (dist_to_target <= 0.6 or current_direction != MoveDirections.VERTICAL)

func check_can_move_right() -> bool:
	#if DEBUG.noclip: return true
	if check_grabbed_obj_direction(3): return false
	return !ray_east.is_colliding() and (dist_to_target <= 0.6 or current_direction != MoveDirections.VERTICAL)

# ↑ Moving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Rotating Stuff ↓

var target_rotation: float
var rotation_speed: float = 8

func rotate_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708
		compass.global_rotation.y = target_rotation
	elif Input.is_action_just_pressed("turn_right"):
		target_rotation = target_rotation - 1.5708
		compass.global_rotation.y = target_rotation

func rotate(delta: float):
	player.rotation.y = lerp_angle(player.rotation.y, target_rotation, delta * rotation_speed)

# ↑ Rotating Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

var is_grabbing_object: bool
var grabbed_obj: Grabbable_Obj

func check_grabbed_obj_direction(dir: int) -> bool: # 0 = north, clockwise
	if !is_grabbing_object: 
		return false
	grabbed_obj.detect_dirs[dir].force_shapecast_update()
	if grabbed_obj.detect_dirs[dir].is_colliding(): 
		return true
	else: return false
