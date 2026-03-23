class_name EnemyState_Chase
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var lost_player: bool

var last_known_location: Vector3

var in_sight: bool
var in_rad: bool

var react_time: float =2 
var has_reacted: bool 

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	wait_timer.wait_time = react_time
	lost_player = false
	
	ballybog.current_alertness = ballybog.ALERTNESS.AGGRO
	ballybog.player.movement.on_move.connect(update_destination)
	
	wait_timer.start()
	ballybog.anim_player.play("Alert")
	#ballybog.movement.start_movement()

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	ballybog.player.movement.on_move.disconnect(update_destination)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	ballybog.movement.update_physics(_delta)
	

func on_heard_something(loc: Vector3) -> void:
	return

func on_player_enter_sight() -> void:
	in_sight = true
	if !lost_player: return
	lost_player = false
	wait_timer.stop()

func on_player_exit_sight() -> void:
	if !in_sight: return
	in_sight = false
	if lost_player: return
	lost_player = !in_rad and !in_sight
	wait_timer.start()

func on_player_enter_aggro_radius() -> void:
	in_rad = true
	if !lost_player: return
	lost_player = false
	wait_timer.stop()

func on_player_exit_aggro_radius() -> void:
	if !in_rad: return
	in_rad = false
	if lost_player: return
	lost_player = !in_rad and !in_sight
	wait_timer.start()

func set_destination()-> void:
	ballybog.movement.set_destination_to_player()
	ballybog.movement.start_movement()

func reached_destination() -> void:
	if !active: return
	#set_destination()

func update_destination(d: Vector3 = Vector3.ZERO,e: Vector3 = Vector3.ZERO) -> void:
	if lost_player: return
	ballybog.movement.add_player_pos_to_destination()
	if !ballybog.movement.is_moving:
		ballybog.movement.start_movement()
	last_known_location = ballybog.player.global_position

func wait_delay_over() -> void:
	if !active: return
	if !has_reacted: 
		wait_timer.wait_time = ballybog.time_before_giveup_chase
		ballybog.movement.set_destination_to_player()
		update_destination()
		ballybog.movement.start_movement()
	else: finished.emit("INVESTIGATE", {"poi": last_known_location, "skip_reaction": true})
