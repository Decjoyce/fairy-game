@icon("res://assets/_editor_icons/icon_bb_stun.svg")
class_name EnemyState_Stunned
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var item_hit_with: Grabbable_Item

var item_dropped_pos: Vector3

var has_seen_player: bool
var can_sense_player: bool
var can_touch_player: bool

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	
	if data.has("stun_force") and data["stun_force"] is float:
		wait_timer.wait_time = 0.1 * data["stun_force"]
	else: wait_timer.wait_time = 1
	
	assert(data.has("item"), "Ballybog tried entering STUNNED state but a item was never passed in")
	assert(data["item"] is Grabbable_Item, "Ballybog tried entering STUNNED state. An item was passed in but it was not a Grabbable_Item")
	item_hit_with = data["item"]
	
	item_dropped_pos = item_hit_with.global_position
	wait_timer.start()
	ballybog.anim_player.play("Stunned")

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	has_seen_player = false
	can_sense_player = false
	can_touch_player = false

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func on_player_enter_sight() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.AGGRO

func on_player_exit_sight() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.SUSPICIOUS

func on_player_enter_aggro_radius() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.AGGRO

func on_player_exit_aggro_radius() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.SUSPICIOUS
func on_player_enter_fight_radius() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.FIGHT

func on_player_exit_fight_radius() -> void:
	ballybog.current_alertness = ballybog.ALERTNESS.AGGRO

func on_hit_with_item(item: Grabbable_Item, force: float) -> void:
	return

func on_heard_something(loc: Vector3) -> void:
	return

func wait_delay_over() -> void:
	if !active: return
	match ballybog.current_alertness:
		2: finished.emit("CHASE", {"skip_reaction": true})
		3:finished.emit("FIGHT")
		_: finished.emit("INVESTIGATE", {"poi": item_dropped_pos, "skip_reaction": true})
