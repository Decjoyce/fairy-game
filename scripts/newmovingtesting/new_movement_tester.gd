extends MeshInstance3D

@export var speed_curve: Curve
@export var crouch_speed_curve: Curve
@export var standing_speed_curve: Curve

var target_pos: Vector3

var is_moving: bool
var speed: float
var speed_mult: float = 5

var dist_to_target: float
var og_dist: float

var crouched: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func move_input() -> void:
		#--> NORTH
	var first_move: bool
	if Input.is_action_just_pressed("move_up"):
		target_pos = target_pos - basis.z * Vector3.ONE
		if !is_moving: first_move = true
	#--> SOUTH
	elif Input.is_action_just_pressed("move_down"):
		target_pos = target_pos + basis.z * Vector3.ONE
		if !is_moving: first_move = true
	#--> EAST
	elif Input.is_action_just_pressed("move_left"):
		target_pos = target_pos - basis.x * Vector3.ONE
		if !is_moving: first_move = true
	#--> WEST
	elif Input.is_action_just_pressed("move_right"):
		target_pos = target_pos + basis.x * Vector3.ONE
		if !is_moving: first_move = true
	
	target_pos.round() 
	target_pos.y = global_position.y
	
	if first_move: og_dist = global_position.distance_to(target_pos)
	
	## MOVEINPUT
	##----------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_input()
	
	if Input.is_action_just_pressed("toggle_crouch"):
		crouched = !crouched
		if crouched: speed_curve = crouch_speed_curve
		else: speed_curve = standing_speed_curve
	
	target_pos.y = global_position.y
	dist_to_target = global_position.distance_to(target_pos)
	
	if dist_to_target > 0.001: ## This is conditioned so we can know if player is moving, to stop them from being able to attack while moving
		speed = speed_curve.sample((og_dist - dist_to_target)/og_dist) * speed_mult
		var weight = 1 - exp(-speed * delta)
		global_position.x = lerpf(global_position.x, target_pos.x, weight)
		global_position.z = lerpf(global_position.z, target_pos.z, weight)
		
		is_moving = true
	else:
		is_moving = false
		global_position = target_pos 
