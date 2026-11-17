@icon("res://assets/_editor_icons/icon_bb_fight.svg")
class_name EnemyState_Fight
extends EnemyState

@onready var wait_timer: Timer = $_wait_timer

var is_attacking: bool
var charge_delay: float = 0.5
var recover_delay: float = 0.5
const ATTACK_RANGE: float = 1.25 ## one cell is 1m, a diagonal 1.41m, so diagonals will miss
const ATTACK_RAY_MASK: int = 9 ## layer 1 + layer 4

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
	_face_player()
	ballybog.anim_player.play("telegraph")
	print("i am chargy")
	wait_timer.wait_time = charge_delay
	wait_timer.start()

func attack() -> void:
	if !active: return
	ballybog.anim_player.play("attack")
	if _can_hit_player():
		print("%s: hit the player" % ballybog.name)
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
	
## Face the cell the player is on or stepping into, keeping the level
func _face_player() -> void:
	var look: Vector3 = ballybog.player.movement.target_pos
	look.y = ballybog.graphics.global_position.y
	if ballybog.graphics.global_position.distance_to(look) < 0.1:
		return # player is on our cell, look_at would fail
	ballybog.graphics.look_at(look, Vector3.UP)
	ballybog.graphics.rotation_degrees.y += 180

## Checked when the swing lands, only ttrue if the player's cell is one cell
## in front and nothing is between the player and myself (the ballybog)
func _can_hit_player() -> bool:
	var me: Vector3 = ballybog.global_position # Fight has already snapped
	var target: Vector3 = ballybog.player.movement.target_pos
	var to_player := Vector3(target.x - me.x, 0.0, target.z - me.z)
	var dist := to_player.length()
	
	if dist > ATTACK_RANGE:
		print("%s: swing missed, player %.2f m away" % [ballybog.name, dist])
		return false
	if dist < 0.5:
		return true # player walked into our cell
		
	# Global basis, some ballybogs are placed rotated, so the local basis points the wrong way
	var facing := ballybog.graphics.global_basis.z
	facing.y = 0.0 
	if facing.normalized().dot(to_player / dist) < 0.7: # within -45 degrees of straight ahead either side
		print("%s: swing missed, player not in front" % ballybog.name)
		return false
	
	# Bodies only, so the player's and ballybog's areas don't count
	var from := me + Vector3.UP * 0.8
	var to := Vector3(target.x, from.y, target.z)
	var query := PhysicsRayQueryParameters3D.create(from, to, ATTACK_RAY_MASK)
	var hit := ballybog.get_world_3d().direct_space_state.intersect_ray(query)
	if !hit.is_empty():
		print("%s: swing blocked by %s" % [ballybog.name, hit.collider.get_path()])
		return false
	return true
