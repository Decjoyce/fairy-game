@icon("res://assets/_editor_icons/icon_bb_chill.svg")
class_name EnemyState_Patrol
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var current_patrol_point: int = 0

func load_me(previous_state_path: String, data : SavedData_Ballybog) -> void:
	super(previous_state_path, data)
	current_patrol_point = data.patrol_current_patrol_point
	
	if data.time_left > 0: wait_timer.wait_time = data.time_left
	else: wait_timer.wait_time = ballybog.delay_between_points
	
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL
	
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	
	wait_timer.wait_time = ballybog.delay_between_points
	
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL
	
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	ballybog.movement.on_reached_destination.disconnect(reached_destination)
	wait_timer.stop()

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	ballybog.movement.update_physics(_delta)

func get_new_point() -> void:
	if !active: return
	current_patrol_point = wrapi(current_patrol_point+1, 0, ballybog.patrol_points.size())
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func reached_destination() -> void:
	if !active: return 
	wait_timer.wait_time = ballybog.delay_between_points
	wait_timer.start()

func wait_delay_over() -> void:
	if !active: return
	get_new_point()
