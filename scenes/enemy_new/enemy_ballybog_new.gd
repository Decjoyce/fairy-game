class_name Enemy_Ballybog_New
extends Entity

var enemy_id: int = 20
var player: PlayerTest

const BB_WEIGHT: int = 10
var freeze : bool

@onready var movement: EnemyMovement = $EnemyMovement
@onready var state_machine: StateMachine_Enemy = $StateMachine
@onready var graphics: Sprite3DBillBoard = $_graphics
@onready var anim_player: AnimationPlayer = $AnimationPlayer

enum ALERTNESS {CHILL, SUSPICIOUS, AGGRO, FIGHT}
var current_alertness: ALERTNESS

@export_group("Detection Settings")
@export var hear_distance: float = 6
@export var los_fov: float = 30
@export var aggro_los_fov: float = 0
@export_flags_3d_physics var player_check_layer_mask: int

@export_group("State Settings")
enum DEFUALT_STATES {IDLE, PATROL, WANDER}
@export var default_state: DEFUALT_STATES = DEFUALT_STATES.PATROL

@export_subgroup("Patrol")
@export var patrol_points: Array[Node3D]
@export var delay_between_points: float = 3
@export var use_random_points: bool = false

@export_subgroup("Wander")
@export var wander_starting_pos: Node3D
var wander_point: Vector3
@export_range(0.5, 19.0) var wander_delay_min: float = 3
@export_range(0.5, 20.0) var wander_delay_max: float = 8

@export_subgroup("CHASE")
@export_range(2, 15) var time_before_giveup_chase: float = 2

var rng:= RandomNumberGenerator.new()

func _ready() -> void:
	current_weight = BB_WEIGHT
	player = get_tree().get_first_node_in_group("Player")
	
	if wander_starting_pos: wander_point = wander_starting_pos.global_position
	else: wander_point = global_position
	
	OMT.on_item_broke.connect(heard_sound)

func _process(delta: float) -> void:
	check_for_player_in_LOS(delta)

func die() -> void:
	freeze = true
	OMT.on_item_broke.disconnect(heard_sound)
	anim_player.play("die")

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Player Checking Stuff ↓

var check_for_player: bool
var player_in_los: bool

func _something_entered_awareness_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		#print("player_ented")
		check_for_player = true

func _something_exited_awareness_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		#print("player_exted")
		check_for_player = false

func player_raycast_check() -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = global_position + Vector3.UP
	var end = player.global_position
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, player_check_layer_mask)
	query.collide_with_areas = true
	#query.hit_from_inside = true
	query.hit_back_faces = true
	var result = space_state.intersect_ray(query)
	if !result or !result.collider or result.collider.get_parent() is not PlayerTest:
		return false
	else: return true

func check_for_player_in_LOS(_delta: float) -> void:
	if !check_for_player: return
	if Engine.get_process_frames() % (10 + enemy_id) != 0: return # stops it running every frame
	
	var dir_to: Vector3 = (global_position * Vector3(1, 0, 1)).direction_to(player.global_position * Vector3(1, 0, 1))
	var angle:float = rad_to_deg((graphics.basis.z).dot(dir_to))
	
	if angle > los_fov: # Checks if player is within the fov of enemy
		#print(angle)
		if player_raycast_check(): # Checks if there is anything blocking enemys los to player
			player_entered_los() ## Player is line of sight
			return
	
	player_exited_los() ## player was not in los

func player_entered_los() -> void:
	if player_in_los: return
	#print("seen u")
	player_in_los = true
	state_machine.state.on_player_enter_sight()

func player_exited_los() -> void:
	if !player_in_los: return
	#print("seen nonono u")
	player_in_los = false
	state_machine.state.on_player_exit_sight()

func _something_entered_aggro_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		state_machine.state.on_player_enter_aggro_radius()

func _something_exited_aggro_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		state_machine.state.on_player_exit_aggro_radius()

func _something_entered_fight_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		state_machine.state.on_player_enter_fight_radius()

func _something_exited_fight_trig(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		state_machine.state.on_player_exit_fight_radius()

# ↑ Player Checking Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ State Stuff ↓

func do_idle() -> void:
	var ran:= rng.randf_range(0.0, 1.0)
	if ran > 0.75: anim_player.play("Idle2")
	else: anim_player.play("Idle")

func _on_item_entered(body: Node3D) -> void:
	if body is Grabbable_Item:
		print(body.prev_velocity.length())
		if body.prev_velocity.length() > 5:
			state_machine.state.on_hit_with_item(body as Grabbable_Item, body.prev_velocity.length())
			body.rb.linear_velocity = (-body.prev_velocity * 0.2)

func heard_sound(loc: Vector3) -> void:
	state_machine.state.on_heard_something(loc)
