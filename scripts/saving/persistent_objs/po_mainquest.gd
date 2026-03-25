@tool
class_name PO_MainQuest
extends PersistentObject

@onready var parent_statue: StatueQuest = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_MainQuest.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.current_stage = parent_statue.current_stage
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_MainQuest:
		parent_statue.current_stage = saved_data.current_stage
		parent_statue.update_graphics()
		parent_statue.itm_receiver.num_have_by_keyword = saved_data.current_stage
		if saved_data.current_stage == 3: parent_statue.itm_receiver.is_activated = true
