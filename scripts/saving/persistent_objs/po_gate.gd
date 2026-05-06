@tool
class_name PO_Gate
extends PersistentObject

@onready var parent_gate: Gate = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Gate.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.current_value = parent_gate.cur_value
	my_data.last_value = parent_gate.last_value
	my_data.is_opening = parent_gate.is_opening
	my_data.end_pos = parent_gate._end_position
	my_data.start_pos = parent_gate._start_position
	my_data.graphics_pos = parent_gate.graphics.global_position.y
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Gate:
		parent_gate._end_position = saved_data.end_pos
		parent_gate._start_position = saved_data.start_pos
		parent_gate.graphics.global_position.y = saved_data.graphics_pos
		parent_gate.cur_value = saved_data.current_value
		parent_gate.last_value = saved_data.last_value
		parent_gate.open_gate_special(saved_data.current_value)
		parent_gate.check_if_disable_col(true)
