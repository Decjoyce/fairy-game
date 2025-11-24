extends Node3D
@export_category("A* Search")
@export var start_tile: Vector3i = Vector3i(-2,0,24)
@export var end_tile: Vector3i = Vector3i(4,0,0)
@export var test_tile: Vector3i = Vector3i(-2,0,18)
@onready var grid_map: GridMapPathFinding = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.setup_astar_grid(grid_map.walkable_items)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	grid_map.do_debug_path(start_tile, end_tile)
