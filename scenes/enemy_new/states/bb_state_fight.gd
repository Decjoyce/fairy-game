@icon("res://assets/_editor_icons/icon_bb_fight.svg")
class_name EnemyState_Fight
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var is_attacking: bool
var charge_delay: float = 0.5
var recover_delay: float = 0.5

var move_to_pos: Tween 

var player_left_radius: bool

var killed_player: bool

func load_me(previous_state_path: String, data : SavedData_Ballybog) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	move_to_pos = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	move_to_pos.set_parallel(true)
	move_to_pos.tween_property(ballybog, "global_position", ballybog.global_position.round(), 0.15)
	charge_attack()
	ballybog.current_alertness = ballybog.ALERTNESS.FIGHT

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	
	move_to_pos = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	move_to_pos.set_parallel(true)
	move_to_pos.tween_property(ballybog, "global_position", ballybog.global_position.round(), 0.15)
	
	charge_attack()
	ballybog.current_alertness = ballybog.ALERTNESS.FIGHT

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)
	wait_timer.stop()
	is_attacking = false
	move_to_pos.stop()
	move_to_pos = null
	player_left_radius = false

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
	#ballybog.movement.update_physics(_delta)

func charge_attack() -> void:
	if !active: return
	ballybog.graphics.look_at(ballybog.player.global_position, Vector3.UP)
	ballybog.graphics.rotation_degrees.y += 180
	ballybog.anim_player.play("telegraph")
	print("i am chargy")
	wait_timer.wait_time = charge_delay
	wait_timer.start()

func attack() -> void:
	if !active: return
	ballybog.anim_player.play("attack")
	print("i attack u")
	killed_player = ballybog.player.stats.take_damage(33.0, 1)
	
	if killed_player:
		if ballybog.rng.randf_range(0, 1) > 0.75:
			ballybog.anim_player.play("boogie")
		else: ballybog.do_idle()
		return
	
	wait_timer.wait_time = charge_delay
	wait_timer.start()

func wait_delay_over() -> void:
	if !active: return
	if killed_player: return
	is_attacking = !is_attacking
	if is_attacking:
		attack()
	else:
		if player_left_radius: 
			finished.emit("CHASE", {"skip_reaction": true})
			return
		charge_attack()

func on_player_exit_fight_radius() -> void:
	if !active: return
	player_left_radius = true

func on_player_enter_sight() -> void:
	return

func on_player_enter_aggro_radius() -> void:
	return

func on_player_enter_fight_radius() -> void:
	if !active: return
	player_left_radius = false

func exit_state_helper() -> void:
	finished.emit("CHASE", {"skip_reaction": true})
