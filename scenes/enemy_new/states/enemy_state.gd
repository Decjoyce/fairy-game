class_name EnemyState extends Node

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

const IDLE = "IDLE"
const WANDER = "WANDER"
const PATROL = "PATROL"
const INVESTIGATE = "INVESTIGATE"
const CHASE = "CHASE"
const FIGHT = "FIGHT"
const STUNNED = "STUNNED"

var sm: StateMachine_Enemy
var ballybog: Enemy_Ballybog_New
var active: bool

func _ready() -> void:
	await owner.ready
	sm = get_parent() as StateMachine_Enemy
	ballybog = owner as Enemy_Ballybog_New
	assert(ballybog != null, "The Enemy state type must be used only in the Enemy scene. It needs the owner to be a enemy_ballybog_new node.")

func load_me(previous_state_path: String, data : SavedData_Ballybog) -> void:
	active = true
	pass

func enter(previous_state_path: String, data := {}) -> void:
	active = true
	pass

func exit() -> void:
	active = false
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func on_player_enter_sight() -> void:
	if !active: return
	#print("j")
	finished.emit("CHASE")

func on_player_exit_sight() -> void:
	pass

func on_player_enter_aggro_radius() -> void:
	if !active: return
	finished.emit("CHASE")

func on_player_exit_aggro_radius() -> void:
	pass

func on_player_enter_fight_radius() -> void:
	if !active: return
	finished.emit("FIGHT")

func on_player_exit_fight_radius() -> void:
	pass

func on_hit_with_item(item: Grabbable_Item, force: float) -> void:
	if !active: return
	finished.emit("STUNNED", {"item": item, "stun_force": force})

func on_heard_something(loc: Vector3) -> void:
	if !active: return
	print(ballybog.global_position.distance_squared_to(loc))
	if ballybog.global_position.distance_to(loc) <= ballybog.hear_distance:
		finished.emit("INVESTIGATE", {"poi": loc})

func wait_delay_over() -> void:
	pass
