extends Node3D

@onready var movement: MovementImproved2 = $MovementImproved2
var target_rotation: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("turn_left"):
		target_rotation = target_rotation + 1.5708
		#compass.global_rotation.y = target_rotation
	elif Input.is_action_just_pressed("turn_right"):
		target_rotation = target_rotation - 1.5708
		#compass.global_rotation.y = target_rotation
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 8)
	
	if Input.is_action_just_pressed("move_up"):
		movement.add_move_amount_vertical(-1)
	elif Input.is_action_just_pressed("move_down"):
		movement.add_move_amount_vertical(1)
	elif Input.is_action_just_pressed("move_left"):
		movement.add_move_amount_horizontal(-1)
	elif Input.is_action_just_pressed("move_right"):
		movement.add_move_amount_horizontal(1)
	
	movement.move(0.001, delta)
