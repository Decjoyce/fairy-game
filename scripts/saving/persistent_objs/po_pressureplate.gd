@tool
class_name PO_PressurePlate
extends PersistentObject

@onready var parent_plate: PressurePlate = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_PressurePlate.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.num_on_plate = parent_plate.get_num_on_plate()
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_PressurePlate:
		parent_plate.saved_num_on_pressure_plate = saved_data.num_on_plate
		if saved_data.num_on_plate == 0:
			parent_plate.load_unlock()
