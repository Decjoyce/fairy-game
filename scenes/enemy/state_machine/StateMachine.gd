class_name NodeStateMachine
extends Node


@export var Init_node_state : NodeState
@export_category("A* stuff")
#@export var curr_tile: Vector3i = Vector3i(-2,0,24)
#@export var goal_tile: Vector3i = Vector3i(4,0,0)
#@export var player_tile: Vector3i = Vector3i(-2,0,18)
#@onready var grid_map: GridMapPathFinding = $GridMap
@export_category("States")
var node_states : Dictionary = {}
var current_node_state : NodeState
var current_node_state_name : String
 
# Called when the node enters the scene tree for the first time.
func _ready() :
	set_process_input(true) 
	for child in get_children():
		if child is NodeState:
			node_states[child.name.to_lower()] = child

	if Init_node_state:
		Init_node_state.enter()
		current_node_state = Init_node_state
#	grid_map.setup_astar_grid(grid_map.walkable_items)

func _physics_process(delta: float) -> void:
	if current_node_state:
		current_node_state.on_physics_process(delta)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) :
	if current_node_state:
		current_node_state.on_process(delta)
		
	##print("Curr State: ", current_node_state.name.to_lower())



func transition_to(node_state_name : String):
	if node_state_name == current_node_state.name.to_lower():
		return
		
	var new_node_state = node_states.get(node_state_name.to_lower())
	
	if !new_node_state:
		return
		
	if current_node_state:
		current_node_state.exit()
	
	new_node_state.enter()
	
	current_node_state = new_node_state
	current_node_state_name = current_node_state_name.to_lower()
