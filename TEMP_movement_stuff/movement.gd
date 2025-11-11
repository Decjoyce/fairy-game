extends Node

@onready var parent: Node3D = get_parent()
@onready var compass: Node3D = $Compass

var is_moving: bool

var position_markers: Array[Vector3]
var target_pos: Vector3
var target_rotation: float

####TEMPPPPPPP
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708
		compass.global_rotation.y = target_rotation
	elif Input.is_action_just_pressed("turn_right"):
		target_rotation = target_rotation - 1.5708
		compass.global_rotation.y = target_rotation
	parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, delta * 8)
	
	if Input.is_action_just_pressed("move_up"):
		add_position_marker(Vector3.FORWARD)
	elif Input.is_action_just_pressed("move_down"):
		add_position_marker(Vector3.BACK)
	elif Input.is_action_just_pressed("move_left"):
		add_position_marker(Vector3.LEFT)
	elif Input.is_action_just_pressed("move_right"):
		add_position_marker(Vector3.RIGHT)
	

func _physics_process(delta: float) -> void:
	move(14.5, delta)

## Camera Bobbing
const BOB_FREQ = 6
const BOB_AMP = 0.07
var t_bob = 0.0
@export var cam : Camera3D

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

####TEMPPPPw

func add_position_marker(position_marker: Vector3) -> void:
	if !Grid_DB.check_grid_space(position_marker):
		position_markers.append(position_marker)
		if position_markers.size() == 1: 
			get_next_pos()

func move(speed: float, delta: float) -> void:
	if position_markers:
		is_moving = true
		parent.global_position.x = lerpf(parent.global_position.x, target_pos.x, speed * delta)
		parent.global_position.z = lerpf(parent.global_position.z, target_pos.z, speed * delta)
		t_bob += delta * (target_pos - parent.global_position).length() * speed ## temp
		cam.h_offset = _headbob(t_bob).x ## temp
		cam.v_offset = _headbob(t_bob).y ## temp
	else:
		is_moving = false
	
	if is_moving and (parent.global_position.x <= target_pos.x + 0.05 and parent.global_position.x >= target_pos.x - 0.05) and (parent.global_position.z <= target_pos.z + 0.05 and parent.global_position.z >= target_pos.z - 0.05):
		position_markers.pop_front()
		if position_markers.size() <= 0:
			parent.global_position.x = target_pos.x
			parent.global_position.z = target_pos.z
		get_next_pos()

func get_next_pos() -> void:
	if position_markers.size() <= 0: return
	var rotated_marker := position_markers[0].rotated(Vector3.UP, compass.rotation.y)
	var rounded_player_pos := parent.global_position.round()
	target_pos = Vector3(rounded_player_pos.x + rotated_marker.x, parent.global_position.y, rounded_player_pos.z + rotated_marker.z)
	print(position_markers[0], rotated_marker)
	compass.global_position = target_pos


###################################################
#func add_position_marker_horizontal(_x_amount: int) -> void:
	#var move_amount := compass.basis.x * (Vector3.ONE * _x_amount)
	#prints("x =", move_amount)
	#if !Grid_DB.check_grid_space(move_amount):
		#position_markers.append(move_amount)
		#if position_markers.size() == 1: 
			#get_next_pos()
#
#func add_position_marker_vertical(_z_amount: int) -> void:
	#var move_amount := compass.basis.z * (Vector3.ONE * _z_amount)
	#prints("z =", move_amount)
	#if !Grid_DB.check_grid_space(move_amount):
		#position_markers.append(move_amount)
		#if position_markers.size() == 1: 
			#get_next_pos()
