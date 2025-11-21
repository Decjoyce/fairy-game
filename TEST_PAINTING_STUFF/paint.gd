extends Node3D

@export var player: PlayerTest
var cam: Camera3D

@export var draw_viewport: DrawViewport

@export var sd: PackedScene

func _ready() -> void:
	cam = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if Input.is_action_pressed("action_LEFT"):
		paint_at_spot()

func paint_at_spot(): # -> Interactable:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(get_viewport().get_mouse_position())
	var end = origin + cam.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result:
		return
	if !result.collider:
		return
	
	#var dude = sd.instantiate()
	#add_child(dude)
	#dude.global_position = result.position
	
	#print(result.collider)
	
	if result.collider.is_in_group("Painterly"):
		#print("paint")
		#print(result.position)
		var uv = LevelUVPosition.get_uv_coords(result.position, result.normal, false)
		#print(uv)
		if uv:
			draw_viewport.paint(uv, Color.RED)
	
