@tool
class_name PO_Bridge
extends PersistentObject

@onready var parent_bridge: BridgeNew = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Bridge.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.current_value = parent_bridge.cur_value
	my_data.last_value = parent_bridge.last_value
	my_data.is_opening = parent_bridge.is_opening
	my_data.end_angle = parent_bridge._end_angle
	my_data.start_angle = parent_bridge._start_angle
	my_data.pivot_rot = parent_bridge.pivot.rotation_degrees.z
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Bridge:
		parent_bridge.pivot.rotation_degrees.z = saved_data.pivot_rot
		parent_bridge.cur_value = saved_data.current_value
		if saved_data.is_opening:
			parent_bridge.begin_bridge_motion(saved_data.current_value)
		parent_bridge.last_value = saved_data.last_value
