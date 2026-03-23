class_name EnemyState_Wander
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer
var rng := RandomNumberGenerator.new()

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.on_reached_destination.connect(reached_pos)
	print(data)
	get_new_pos()
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL

func exit() -> void:
	super()
	ballybog.movement.on_reached_destination.disconnect(reached_pos)
	wait_timer.timeout.disconnect(wait_delay_over)
	wait_timer.stop()

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	ballybog.movement.update_physics(_delta)

func get_new_pos() -> void:
	if !active: return
	ballybog.movement.get_random_destination(true)
	ballybog.movement.start_movement()

func reached_pos() -> void:
	if !active: return
	wait_timer.wait_time = rng.randf_range(ballybog.wander_delay_min, ballybog.wander_delay_max)
	wait_timer.start()

func wait_delay_over() -> void:
	if !active: return
	get_new_pos()
