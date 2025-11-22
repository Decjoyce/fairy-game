extends MarginContainer

@onready var node3dhelper: Node3D = $node3dhelper

var cam: Camera3D

var current_objects_methods: Array = []

func _ready() -> void:
	await owner.ready
	#cam = Debug.player.cam

func select_object() -> void:
	var space_state = node3dhelper.get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * INF
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider:
		return
	
	if result.collider is Interactable:
		pass
