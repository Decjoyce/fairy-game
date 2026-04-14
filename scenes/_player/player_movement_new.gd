class_name PlayerMovement
extends Node

@export var player: PlayerTest
@export var interact: PlayerInteract

@onready var compass: Node3D = $Compass

@onready var ray_north: ShapeCast3D = $Compass/North ## Checks if player can move forward and also temporary interact
@onready var ray_east: ShapeCast3D = $Compass/East ## Checks if player can move right
@onready var ray_south: ShapeCast3D = $Compass/South ## Checks if player can move back
@onready var ray_west: ShapeCast3D = $Compass/West ## Checks if player can move left
@export var floor_detector: RayCast3D ## Checks if player can move left
@export var roof_detector: RayCast3D ## Checks if player can move left

@export var disable_gravity: bool = false

@export var col: CollisionShape3D
@export var col_helper_uncrouched: CollisionShape3D
@export var col_helper_crouched: CollisionShape3D

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Moving Stuff ↓

var is_moving: bool
var target_pos: Vector3
const SPEED_MAX: float = 4.5
const SPEED_CROUCH: float = 2.25
var speed: float = 4.5

const FALL_SPEED: float = 8.5
var current_fall_speed: float = 0
var start_fall_height: float = 0

var dist_to_target: float

enum MoveDirections {NOT_MOVING, VERTICAL, HORIZONTAL, FALLING}
var current_direction: MoveDirections

signal on_move(direction: Vector2, target_position: Vector3)
signal on_move_up(target_position: Vector3)
signal on_move_down(target_position: Vector3)
signal on_move_left(target_position: Vector3)
signal on_move_right(target_position: Vector3)

signal on_turn(target_rotation: float)
signal on_turn_left(target_rotation: float)
signal on_turn_right(target_rotation: float)

signal on_crouch(crouched: bool)

var was_holding: bool

func _ready() -> void:
	var dd: =player.global_position.round()
	var new_position := Vector3(dd.x, player.global_position.y, dd.z)
	var new_rotation := player.global_rotation.y
	
	is_moving = false
	
	target_pos = new_position
	target_rotation = new_rotation
	
	compass.global_position = new_position
	compass.global_rotation.y = new_rotation
	
	player.global_position = new_position
	player.global_rotation.y = new_rotation
	
	current_direction = MoveDirections.NOT_MOVING
	
	ray_north.force_shapecast_update()
	ray_south.force_shapecast_update()
	ray_east.force_shapecast_update()
	ray_west.force_shapecast_update()
	
	crouch()
	uncrouch()

func _process(delta: float) -> void:
	$Label.text = str(current_sprint_step)
	$Label.text += "\n" + str(is_recovering)
	if is_recovering: 
		current_recovery_time += delta
		#var mapped_d:= remap(current_recovery_time/current_ttr, 0, 1, 0, 0.765)
		#print(mapped_d)
		#player.post_processing.set_shader_parameter("saturation", mapped_d)
		if current_recovery_time >= 1:
			$TextureRect.visible = false
		
		if current_recovery_time >= current_ttr:
			current_sprint_step = 0
			is_recovering = false
			player.post_processing.set_shader_parameter("saturation", 0.765)
			#$TextureRect.visible = false
	$Label.text += "\n" + str(current_recovery_time)

func movement_input() -> void:
	## MOVEINPUT
	#--> NORTH
	if Input.is_action_pressed("move_up") and !Input.is_action_just_pressed("move_up") and !Input.is_action_just_released("move_up") and check_can_move_up():
		if dist_to_target > 0.2: return
		target_pos = target_pos - compass.basis.z * Vector3.ONE
		current_direction = MoveDirections.VERTICAL
		
		on_move.emit(Vector3.FORWARD, target_pos)
		on_move_up.emit(target_pos)
		
		was_holding = true
		footstep_audio.play()
	#--> SOUTH
	elif Input.is_action_pressed("move_down") and check_can_move_down() :# and !Input.is_action_just_pressed("move_down") and !Input.is_action_just_released("move_down")
		if dist_to_target > 0.2: return
		target_pos = target_pos + compass.basis.z * Vector3.ONE
		current_direction = MoveDirections.VERTICAL
		
		on_move.emit(Vector3.BACK, target_pos)
		on_move_down.emit(target_pos)
		
		footstep_audio.play()
		was_holding = true
	#--> EAST
	elif Input.is_action_pressed("move_left") and check_can_move_left() :# and !Input.is_action_just_pressed("move_left") and !Input.is_action_just_released("move_left")
		if dist_to_target > 0.2: return
		target_pos = target_pos - compass.basis.x * Vector3.ONE
		
		current_direction = MoveDirections.HORIZONTAL
		
		on_move.emit(Vector3.LEFT, target_pos)
		on_move_left.emit(target_pos)
		
		footstep_audio.play()
		was_holding = true
	#--> WEST
	elif Input.is_action_pressed("move_right") and check_can_move_right() :# and !Input.is_action_just_pressed("move_right") and !Input.is_action_just_released("move_right"):
		if dist_to_target > 0.2: return
		target_pos = target_pos + compass.basis.x * Vector3.ONE
		current_direction = MoveDirections.HORIZONTAL
		
		on_move.emit(Vector3.RIGHT, target_pos)
		on_move_right.emit(target_pos)
		
		footstep_audio.play()
		was_holding = true
	## MOVEINPUT
	##----------
	if floor_detector.is_colliding() and Input.is_action_just_pressed("toggle_crouch") and dist_to_target <= 0.6:
		toggle_crouch()
	
	target_pos.round() 
	target_pos.y = player.global_position.y
	compass.global_position = target_pos

func movement(delta: float) -> void:
	target_pos.round() 
	
	#print(floor_detector.is_colliding())
	gravity(delta)
	
	target_pos.y = player.global_position.y
	dist_to_target = player.global_position.distance_to(target_pos)
	
	if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
		#t_bob += delta * (target_pos - player.position).length() * speed ## some headbobbing formula i used before. Its really bad.
		var weight = 1 - exp(-speed * delta)
		player.global_position.x = lerpf(player.global_position.x, target_pos.x, weight)
		player.global_position.z = lerpf(player.global_position.z, target_pos.z, weight)
		
		if floor_detector.is_colliding():
			player.global_position.y = floor_detector.get_collision_point().y + player.current_player_height
		
		t_bob += delta * ((target_pos - player.global_position).length() * speed)
		var bob := _headbob(t_bob)
		player.cam.h_offset = bob.x
		player.cam.v_offset = bob.y
		
		is_moving = true
	else:
		is_moving = false
		player.global_position = target_pos 

func check_can_move_up() -> bool:
	if Debug.noclip_enabled: return true
	if check_grabbed_obj_direction(0): return false
	ray_north.force_shapecast_update()
	return !ray_north.is_colliding() and (dist_to_target <= 0.45 or current_direction != MoveDirections.HORIZONTAL) and current_direction != MoveDirections.FALLING

func check_can_move_down() -> bool:
	if Debug.noclip_enabled: return true
	if check_grabbed_obj_direction(1): return false
	ray_south.force_shapecast_update()
	return !ray_south.is_colliding() and (dist_to_target <= 0.45 or current_direction != MoveDirections.HORIZONTAL) and current_direction != MoveDirections.FALLING

func check_can_move_left() -> bool:
	if Debug.noclip_enabled: return true
	if check_grabbed_obj_direction(2): return false
	ray_west.force_shapecast_update()
	return !ray_west.is_colliding() and (dist_to_target <= 0.45 or current_direction != MoveDirections.VERTICAL) and current_direction != MoveDirections.FALLING

func check_can_move_right() -> bool:
	if Debug.noclip_enabled: return true
	if check_grabbed_obj_direction(3): return false
	ray_east.force_shapecast_update()
	return !ray_east.is_colliding() and (dist_to_target <= 0.45 or current_direction != MoveDirections.VERTICAL) and current_direction != MoveDirections.FALLING

# ↑ Moving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Sprinting Stuff ↓

var current_sprint_step: int
var max_sprint_step: int = 7

var is_recovering: bool
var current_recovery_time: float = 0
var current_ttr: float = 3.0
const OOS_TTR: float = 8.0
const NORMAL_TTR: float = 3.0

func movement_input_sprint() -> void:
	if is_crouching: return
	## MOVEINPUT
	#--> NORTH
	if Input.is_action_just_released("move_up") and check_can_move_up():
		if was_holding:
			was_holding = false
			return
		
		if current_sprint_step == max_sprint_step: return
		target_pos = target_pos - compass.basis.z * Vector3.ONE
		current_direction = MoveDirections.VERTICAL
		
		on_move.emit(Vector3.FORWARD, target_pos)
		on_move_up.emit(target_pos)
		
		current_sprint_step += 1
		
		$TextureRect.visible = true
		footstep_audio.play()
		check_recover()
	##--> SOUTH
	#elif Input.is_action_just_released("move_down") and check_can_move_down():
		#if was_holding:
			#was_holding = false
			#return
		#
		#if current_sprint_step == max_sprint_step: return
		#target_pos = target_pos + compass.basis.z * Vector3.ONE
		#current_direction = MoveDirections.VERTICAL
		#
		#on_move.emit(Vector3.BACK, target_pos)
		#on_move_down.emit(target_pos)
		#
		#current_sprint_step += 1
		#
		#footstep_audio.play()
		#check_recover()
	##--> EAST
	#elif Input.is_action_just_released("move_left") and check_can_move_left():
		#if was_holding:
			#was_holding = false
			#return
		#
		#if current_sprint_step == max_sprint_step: return
		#target_pos = target_pos - compass.basis.x * Vector3.ONE
		#
		#current_direction = MoveDirections.HORIZONTAL
		#
		#on_move.emit(Vector3.LEFT, target_pos)
		#on_move_left.emit(target_pos)
		#
		#current_sprint_step += 1
		#
		#footstep_audio.play()
		#check_recover()
	##--> WEST
	#elif Input.is_action_just_released("move_right") and check_can_move_right():
		#if was_holding:
			#was_holding = false
			#return
		#
		#if current_sprint_step == max_sprint_step: return
		#target_pos = target_pos + compass.basis.x * Vector3.ONE
		#current_direction = MoveDirections.HORIZONTAL
		#
		#on_move.emit(Vector3.RIGHT, target_pos)
		#on_move_right.emit(target_pos)
		#
		#current_sprint_step += 1
		#
		#footstep_audio.play()
		#check_recover()
	## MOVEINPUT
	##----------
	

	
	target_pos.round() 
	target_pos.y = player.global_position.y
	compass.global_position = target_pos

func check_recover() -> void:
	var mapped_d:= remap(current_sprint_step, 0, max_sprint_step, 0.765, 0)
	#print(mapped_d)
	player.post_processing.set_shader_parameter("saturation", mapped_d)
	#if current_sprint_step == max_sprint_step: current_ttr = OOS_TTR
	#else: current_ttr = NORMAL_TTR
	current_ttr = float(current_sprint_step)
	
	start_step_recovery()

func start_step_recovery() -> void:
	current_recovery_time = 0
	is_recovering = true

# ↑ Sprinting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Rotating Stuff ↓

var target_rotation: float
var rotation_speed: float = 8

func rotate_input() -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708
		compass.global_rotation.y = target_rotation
		on_turn.emit(target_rotation)
		on_turn_left.emit(target_rotation)
	elif Input.is_action_just_pressed("turn_right"):
		target_rotation = target_rotation - 1.5708
		compass.global_rotation.y = target_rotation
		on_turn.emit(target_rotation)
		on_turn_right.emit(target_rotation)

func rotate(delta: float):
	var weight = 1 - exp(-rotation_speed * delta)
	player.rotation.y = lerp_angle(player.rotation.y, target_rotation, weight)
	if player.rotation.y <= target_rotation + 0.001 and player.rotation.y >= target_rotation - 0.001:
		player.rotation.y = target_rotation

# ↑ Rotating Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Crouching Stuff ↓

var is_crouching: bool

func toggle_crouch() -> void:
	if is_crouching: uncrouch()
	else: crouch()

func crouch(bypass_floor_detection: bool = false) -> void:
	if !bypass_floor_detection and !floor_detector.get_collision_point(): return
	is_crouching = true
	
	on_crouch.emit(true)
	
	col.shape = col_helper_crouched.shape
	col.position.y = col_helper_crouched.position.y
	
	player.current_player_height = player.PLAYER_HEIGHT_CROUCHED
	speed = SPEED_CROUCH
	player.global_position.y = floor_detector.get_collision_point().y + player.current_player_height
	roof_detector.enabled = true

func uncrouch() -> void:
	if !floor_detector.is_colliding(): return
	if roof_detector.is_colliding(): return
	is_crouching = false
	
	on_crouch.emit(false)
	
	col.shape = col_helper_uncrouched.shape
	col.position.y = col_helper_uncrouched.position.y
	
	player.current_player_height = player.PLAYER_HEIGHT
	speed = SPEED_MAX
	player.global_position.y = floor_detector.get_collision_point().y + player.current_player_height
	
	roof_detector.enabled = false

# ↑ Crouching Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Falling Stuff ↓

func gravity(delta: float) -> void:
	if !disable_gravity and !Debug.noclip_enabled and !floor_detector.is_colliding():
		if current_direction != MoveDirections.FALLING:
			current_direction = MoveDirections.FALLING
			start_fall_height = player.global_position.y
		current_fall_speed = clampf(current_fall_speed + 4, 0.1, FALL_SPEED)
		player.global_position.y -= current_fall_speed * delta
	elif current_direction == MoveDirections.FALLING:
		if abs(player.global_position.y - start_fall_height) >= 4:
			player.stats.take_damage(10000)
		player.global_position.y = floor_detector.get_collision_point().y + player.current_player_height
		current_direction = MoveDirections.NOT_MOVING
		current_fall_speed = 0

# ↑ Falling Stuff ↑
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

# ↑ Grabbing Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Teleport Stuff ↓

func teleport_player(out_pos: Node3D) -> void:
	var new_position := out_pos.global_position.round()
	var new_rotation := out_pos.global_rotation.y
	
	is_moving = false
	
	target_pos = new_position
	target_rotation = new_rotation
	
	compass.global_position = new_position
	compass.global_rotation.y = new_rotation
	
	player.global_position = new_position
	player.global_rotation.y = new_rotation
	
	current_direction = MoveDirections.NOT_MOVING
	
	ray_north.force_shapecast_update()
	ray_south.force_shapecast_update()
	ray_east.force_shapecast_update()
	ray_west.force_shapecast_update()
	

func teleport_player_by_coords(out_pos: Vector3) -> void:
	var new_position := out_pos.round()
	
	is_moving = false
	
	target_pos = new_position
	
	compass.global_position = new_position
	
	player.global_position = new_position
	
	current_direction = MoveDirections.NOT_MOVING
	
	ray_north.force_shapecast_update()
	ray_south.force_shapecast_update()
	ray_east.force_shapecast_update()
	ray_west.force_shapecast_update()

# ↑ Teleport Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Headbob & Footsteps Stuff ↓

var t_bob: float
@export var BOB_FREQ: float
@export var  BOB_AMP: float

var footstep_can_play: bool
@onready var footstep_audio: AudioStreamPlayer3D = %FootstepAudio

func _headbob(time: float) -> Vector2:
	var pos = Vector2.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	
	#print(-pos.y)
	#var footstep_threshold = -BOB_AMP + 0.035# 0.04
	#if pos.y > footstep_threshold:
		#footstep_can_play = true
	#elif pos.y < footstep_threshold and footstep_can_play:
		#footstep_can_play = false
		#footstep_audio.play()
		
	
	return pos
