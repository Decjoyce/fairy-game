class_name HandState_Saving
extends HandState

var save_stone: SavingStone
var tween: Tween
var hand_place: Vector2
var begin_charging: bool
var value: float
var time_since_start_charge: float

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type):
		finished.emit(FREE)
		return
	if !begin_charging or value >= 1.0: return
	update_value(_delta)

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.animation_player.play(anim_idle)
	save_stone = hand_controller.current_interactable 
	var hp := save_stone.get_hand_place(hand_controller.hand_type)
	hand_place = get_viewport().get_camera_3d().unproject_position(hp.global_position)
	hand_place -= hand_controller.size/2
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(hand_controller, "global_position", hand_place, 0.075)
	await tween.finished
	begin_charging = true

func exit() -> void:
	save_stone.end_interact()
	save_stone = null
	tween.stop()
	tween = null
	time_since_start_charge = 0
	value = 0

func update_value(_delta: float) -> void:
	time_since_start_charge += _delta
	value = clampf(time_since_start_charge / save_stone.charge_length, 0, 1.0)
	var done:= save_stone.update_val(hand_controller.hand_type, value)
	if done: player_interact.force_stop_interacting() # temp
