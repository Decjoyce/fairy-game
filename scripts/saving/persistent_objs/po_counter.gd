@tool
class_name PO_Counter
extends PersistentObject

@onready var parent_counter: Counter = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Counter.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.current_count = parent_counter.current_count
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Counter:
		parent_counter.current_count = saved_data.current_count
