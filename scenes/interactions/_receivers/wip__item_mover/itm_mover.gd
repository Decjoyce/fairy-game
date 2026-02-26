extends Node

@export var itms_2_move: Array[Node3D]
@export var positions_to_move_to: Array[Node3D]

var tween: Tween
@export_range(0, 1.0, 0.01) var smooth_move_weight: float = 0.1

@export var cur_item_index: int = 0 ## This item will be moved when "move_item_from_index" is called

func _ready() -> void:
	if positions_to_move_to.size() <= 0 and get_child_count() > 0: 
		for i in get_children():
			positions_to_move_to.append(i)

func set_current_index(indx: int) -> void:
	cur_item_index = indx

func move_item_from_index(sig: float) -> void:
	assert(positions_to_move_to[0], "ITM_MOVER: No positions assigned")
	assert(itms_2_move[0], "ITM_MOVER: No items assigned")
	
	var new_pos: Node3D = positions_to_move_to[0]
	if positions_to_move_to[cur_item_index]: new_pos = positions_to_move_to[cur_item_index]
	itms_2_move[cur_item_index].global_position = new_pos.global_position
	itms_2_move[cur_item_index].global_rotation = new_pos.global_rotation

func smooth_move_item_from_index(sig: float) -> void:
	assert(positions_to_move_to[0], "ITM_MOVER: No positions assigned")
	assert(itms_2_move[0], "ITM_MOVER: No items assigned")
	
	var new_pos: Node3D = positions_to_move_to[0]
	if positions_to_move_to[cur_item_index]: new_pos = positions_to_move_to[cur_item_index]
	
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(itms_2_move[cur_item_index], "global_position", new_pos.global_position, smooth_move_weight)
	tween.tween_property(itms_2_move[cur_item_index], "global_rotation", new_pos.global_rotation, smooth_move_weight)

func move_all_items(sig: float) -> void:
	assert(positions_to_move_to[0], "ITM_MOVER: No positions assigned")
	for i in itms_2_move.size():
		if !itms_2_move[i]: continue
		var new_pos: Node3D = positions_to_move_to[0]
		if positions_to_move_to[i]: new_pos = positions_to_move_to[i]
		itms_2_move[i].global_position = new_pos.global_position
		itms_2_move[i].global_rotation = new_pos.global_rotation

func smooth_move_all_items(sig: float) -> void:
	assert(positions_to_move_to[0], "ITM_MOVER: No positions assigned")
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	for i in itms_2_move.size():
		var new_pos: Node3D = positions_to_move_to[0]
		if positions_to_move_to[i]: new_pos = positions_to_move_to[i]
		tween.tween_property(itms_2_move[i], "global_position", new_pos.global_position, smooth_move_weight)
		tween.tween_property(itms_2_move[i], "global_rotation", new_pos.global_rotation, smooth_move_weight)
