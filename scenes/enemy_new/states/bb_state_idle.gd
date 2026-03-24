@icon("res://assets/_editor_icons/icon_bb_chill.svg")
class_name EnemyState_Idle
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	ballybog.current_alertness = ballybog.ALERTNESS.CHILL
	ballybog.do_idle()
	wait_timer.timeout.connect(wait_delay_over)

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func wait_delay_over() -> void:
	if !active: return
	ballybog.do_idle()
	wait_timer.start()
