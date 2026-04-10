class_name StateMachine_Enemy
extends Node

@export var ballybog: Enemy_Ballybog_New

@onready var default_state: EnemyState = get_default_state()
## The current state of the state machine.
@onready var state: EnemyState = get_default_state()

func _ready() -> void:
	for state_node: EnemyState in find_children("*", "EnemyState"):
		state_node.finished.connect(_transition_to_next_state)

	await owner.ready
	state.enter("")

func get_default_state() -> EnemyState: 
	return get_child(ballybog.default_state)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	
	prints("From", state, "to", target_state_path)
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

func load_states(sd: SavedData_Ballybog) -> void:
	if not has_node(sd.current_state):
		printerr(owner.name + ": Trying to transition to state " + sd.current_state + " but it does not exist.")
		return
	
	prints("LOADING STATE :: From", state, "to", sd.current_state)
	var previous_state_path := state.name
	state.exit()
	state = get_node(sd.current_state)
	state.load_me(previous_state_path, sd)
