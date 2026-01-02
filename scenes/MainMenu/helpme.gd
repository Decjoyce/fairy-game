extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	pass # Replace with function body.

var is_free: bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("free_mouse"):
		is_free = !is_free
		if is_free: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	#if is_free: return
	var z_input = Input.get_axis("turn_left", "turn_right")
	
	var x_input = Input.get_axis("move_left", "move_right")
	
	var y_input = Input.get_axis("move_down", "move_up")
	$Y_ROT.position.y += y_input * delta
	$Y_ROT.position.x += x_input * delta
	$Y_ROT.position.z += z_input * delta
	
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !is_free:
		$Y_ROT.rotate_y(-event.relative.x * mouse_sensitivity)
		$Y_ROT/X_ROT.rotate_x(-event.relative.y * mouse_sensitivity)
		$Y_ROT/X_ROT.rotation.x = clampf($Y_ROT/X_ROT.rotation.x, -deg_to_rad(70), deg_to_rad(70))

var mouse_sensitivity = 0.002
