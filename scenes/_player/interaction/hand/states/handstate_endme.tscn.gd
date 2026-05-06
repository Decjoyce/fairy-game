class_name HandState_End
extends HandState


var reset_pos: Vector2


func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.input_controls.visible = false
	hand_controller.animation_player.play("end_anim")
	if hand_controller.hand_type == 0: 
		reset_pos = Vector2((player_interact.size.x/2.2) - (hand_controller.size.x/2), player_interact.size.y/2)
	else: reset_pos = Vector2((player_interact.size.x - (player_interact.size.x/2.2)) - (hand_controller.size.x/2), player_interact.size.y/2)
	
	var tween := get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(hand_controller, "global_position", reset_pos, 0.15)
	await get_tree().create_timer(1).timeout
	if hand_controller.hand_type == 0: 
		reset_pos = Vector2((player_interact.size.x/2.4) - (hand_controller.size.x/2), player_interact.size.y/2)
	else: reset_pos = Vector2((player_interact.size.x - (player_interact.size.x/2.4)) - (hand_controller.size.x/2), player_interact.size.y/2)
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(hand_controller, "global_position", reset_pos, 0.15)
	await get_tree().create_timer(1.05).timeout
	if hand_controller.hand_type == 0: 
		reset_pos = Vector2((player_interact.size.x/2.2) - (hand_controller.size.x/2), player_interact.size.y/2.7)
	else: reset_pos = Vector2((player_interact.size.x - (player_interact.size.x/2.4)) - (hand_controller.size.x/2), player_interact.size.y/2)
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(hand_controller, "global_position", reset_pos, 0.15)
