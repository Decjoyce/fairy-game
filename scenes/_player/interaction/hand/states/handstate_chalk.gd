class_name HandState_Chalk
extends HandState

var is_drawing: bool

@export var dist_to_draw: float

var last_pos: Vector2

var cam: Camera3D

var draw_viewport: DrawViewport

@export var offset_helper: Control


func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if Input.is_action_pressed("action_" + hand_controller.stringed_hand_type):
		if hand_controller.position.distance_squared_to(last_pos) > dist_to_draw:
			draw_chalk()
	
	if Input.is_action_just_pressed("enter_paint_mode_" + hand_controller.stringed_hand_type):
		finished.emit(FREE)
	
	last_pos = hand_controller.position

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	cam = hand_controller.cam
	hand_controller.animation_player.play("hand_prompt_door_locked")

func exit() -> void:
	pass

func draw_chalk() -> void:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(offset_helper.get_screen_position())
	var end = origin + cam.project_ray_normal(offset_helper.get_screen_position()) * player_interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result:
		return
	if !result.collider:
		return
	
	if result.collider.is_in_group("DrawBoards"):
		var draw_board : DrawBoard = result.collider.get_parent() as DrawBoard
		draw_viewport = draw_board.draw_viewport
		var uv = draw_board.get_uv_coords(result.position, result.normal, true)
		if uv:
			
			draw_viewport.paint(uv, Color.RED)
