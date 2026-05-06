@icon("res://assets/_editor_icons/icon_bb_sus.svg")
class_name EnemyState_Investigate
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer
@onready var giveup_timer: Timer = $_delay_before_give_up
var reaction_delay: float = 2
var time_to_investigate: float = 3
var time_before_new_pos: float = 2
var time_before_giveup: float = 15

var current_poi: Vector3

var current_investigate_state: int = 0 # 0 -> Reacting to noise , 1 -> Investigating Noise , 2 -> Searching Area

func load_me(previous_state_path: String, data : SavedData_Ballybog) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	giveup_timer.timeout.connect(give_up)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	
	current_investigate_state = data.inv_current_investigate_state
	current_poi = data.inv_poi
	wait_timer.wait_time = data.time_left
	
	match current_investigate_state:
		1: 
			ballybog.movement.set_new_destination(current_poi)
			ballybog.movement.start_movement()
			wait_timer.start()
		2:
			giveup_timer.wait_time = data.inv_giveup_timeleft
			giveup_timer.start()
			wait_timer.start()
		3:
			get_ran_pos()
			wait_timer.start()

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	
	wait_timer.timeout.connect(wait_delay_over)
	giveup_timer.timeout.connect(give_up)
	ballybog.movement.on_reached_destination.connect(reached_destination)
	
	assert(data.has("poi"), "Ballybog tried entering INVESTIGATE state but a [poi] was never passed in")
	assert(data["poi"] is Vector3, "Ballybog tried entering INVESTIGATE state. A [poi] was passed in but it was not a Vector3")
	current_poi = data["poi"]
	
	if data.has("skip_reaction") and data["skip_reaction"] == true:
		start_investigation()
		return
	
	ballybog.graphics.look_at(current_poi, Vector3.UP)
	ballybog.graphics.rotation_degrees.y += 180
	ballybog.current_alertness = ballybog.ALERTNESS.SUSPICIOUS
	
	current_investigate_state = 0
	wait_timer.wait_time = reaction_delay
	wait_timer.start()
	ballybog.anim_player.play("Alert")

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	giveup_timer.timeout.disconnect(give_up)
	ballybog.movement.on_reached_destination.disconnect(reached_destination)
	wait_timer.stop()
	giveup_timer.stop()

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	ballybog.movement.update_physics(_delta)

func reached_destination() -> void:
	if !active: return
	ballybog.anim_player.play("Idle2")
	wait_timer.start()

func get_ran_pos() -> void:
	if !active: return
	ballybog.movement.get_random_destination()
	ballybog.movement.start_movement()

func start_investigation() -> void:
	current_investigate_state = 1
	wait_timer.wait_time = time_to_investigate
	ballybog.movement.set_new_destination(current_poi)
	ballybog.movement.start_movement()
	wait_timer.start()

func wait_delay_over() -> void:
	if !active: return
	match current_investigate_state:
		0:  
			start_investigation()
		1:
			wait_timer.wait_time = time_before_new_pos
			giveup_timer.wait_time = time_before_giveup
			current_investigate_state = 2
			giveup_timer.start()
			wait_timer.start()
		2: 
			get_ran_pos()
			wait_timer.start()

func give_up() -> void:
	if !active: return
	print("ko")
	finished.emit(sm.default_state.name)
