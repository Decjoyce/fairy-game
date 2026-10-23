@icon("res://assets/_editor_icons/icon_bb_chill.svg")
class_name EnemyState_Patrol
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var current_patrol_point: int = 0
var bounce_mult: int = -1

func load_me(previous_state_path: String, data : SavedData_Ballybog) -> void:
	super(previous_state_path, data)
	## Prevent out of bounds indexing
	current_patrol_point = clampi(data.patrol_current_patrol_point, 0, maxi(ballybog.patrol_points.size() - 1, 0))
	
	if data.time_left > 0: wait_timer.wait_time = data.time_left
	else: wait_timer.wait_time = ballybog.delay_between_points
	
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	ballybog.movement.path_failed.connect(skip_unreachable_point)
	
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL
	
	if ballybog.patrol_points.is_empty():
		push_warning("%s: PATROL has no patrol points, standing still" % ballybog.name)
		return
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	
	wait_timer.wait_time = ballybog.delay_between_points
	
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	ballybog.movement.path_failed.connect(skip_unreachable_point)
	
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL
	
	if ballybog.patrol_points.is_empty():
		push_warning("%s: PATROL has no patrol points, standing still" % ballybog.name)
		return
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	ballybog.movement.on_reached_destination.disconnect(reached_destination)
	ballybog.movement.path_failed.disconnect(skip_unreachable_point)
	wait_timer.stop()

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	ballybog.movement.update_physics(_delta)

func get_new_point() -> void:
	if !active: return
	var count := ballybog.patrol_points.size()
	match ballybog.patrol_loop_mode:
		Enemy_Ballybog_New.LOOP_MODES.LOOP:
			current_patrol_point = wrapi(current_patrol_point + 1, 0, count)
		Enemy_Ballybog_New.LOOP_MODES.BOUNCE:
			if count < 2: return
			if current_patrol_point + bounce_mult < 0 or current_patrol_point + bounce_mult >= count:
				bounce_mult *= -1 # hit an end, turn around
			current_patrol_point += bounce_mult
		Enemy_Ballybog_New.LOOP_MODES.DO_ONCE:
			if current_patrol_point >= count - 1: return # route done, stay at the last point
			current_patrol_point += 1
		Enemy_Ballybog_New.LOOP_MODES.RANDOM:
			if count < 2: return
			var next := randi_range(0, count - 2)
			current_patrol_point = next if next < current_patrol_point else next + 1 # never the same point twice in a row
	ballybog.movement.set_new_destination(ballybog.patrol_points[current_patrol_point].global_position)
	ballybog.movement.start_movement()

func reached_destination() -> void:
	if !active: return 
	print("reachdestination")
	ballybog.do_idle()
	wait_timer.wait_time = ballybog.delay_between_points
	wait_timer.start()

func wait_delay_over() -> void:
	if !active: return
	get_new_point()
	
func skip_unreachable_point() -> void:
	if !active: return
	push_warning("%s: can't reach patrol point %s, skipping it" % [ballybog.name, ballybog.patrol_points[current_patrol_point].name])
	wait_timer.wait_time = ballybog.delay_between_points
	wait_timer.start()
