class_name EnemyState_Dead
extends EnemyState

## po_ballybog saves state.wait_timer.time_left, so every state needs one
@onready var wait_timer: Timer = $_wait_timer

func load_me(previous_state_path: String, data: SavedData_Ballybog) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.stats.is_dead = true # the scene was reloaded, so Stats doesn't know yet
	_remove_body() # skip the animation, go straight to gone

func enter(previous_state_path: String, data := {}) -> void:
	super(previous_state_path, data)
	wait_timer.timeout.connect(wait_delay_over)
	ballybog.movement.stop_movement()
	ballybog.anim_player.play("death")
	wait_timer.wait_time = ballybog.anim_player.get_animation("death").length
	wait_timer.start()
	print("%s: died" % ballybog.name)

func exit() -> void:
	super()
	wait_timer.timeout.disconnect(wait_delay_over)

## Death animation done: hide the body and switch the Ballybog off.
## Not freed, so PO_Ballybog keeps saving it as DEAD.
func wait_delay_over() -> void:
	if !active: return
	_drop_item()
	_remove_body()

func _drop_item() -> void:
	if ballybog.drop_item == null: return
	var item: Grabbable_Item = ballybog.drop_item.instantiate()
	get_tree().current_scene.add_child(item) # add it to the tree first, global_position needs that
	item.non_scene_native = true # spawned at runtime, so the save stores it by scene path
	item.global_position = ballybog.global_position + Vector3.UP * 0.5
	print("%s: dropped %s" % [ballybog.name, item.name])

func _remove_body() -> void:
	ballybog.stats.hit_sfx.process_mode = Node.PROCESS_MODE_PAUSABLE
	ballybog.visible = false
	ballybog.disable_me()
	print("%s: body gone" % ballybog.name)

# DEAD is final: block everything that would change state
func on_player_enter_sight() -> void:
	return

func on_player_enter_aggro_radius() -> void:
	return

func on_player_enter_fight_radius() -> void:
	return

func on_hit_with_item(_item: Grabbable_Item, _force: float) -> void:
	return

func on_heard_something(_loc: Vector3) -> void:
	return
