@tool
class_name PO_IntValue
extends PersistentObject

@onready var parent_intvalue = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_IntValuer.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.value = parent_intvalue.current_value
	my_data.disabled = parent_intvalue.disabled
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_IntValuer:
		parent_intvalue.update_value(saved_data.value)
		if saved_data.disabled: parent_intvalue.disable()
