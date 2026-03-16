@tool
class_name PO_SpikeTrap
extends PersistentObject

@onready var parent_st: SpikeTrap = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_SpikeTrap.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.activated = parent_st.activated
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_SpikeTrap:
		if saved_data.activated:
			parent_st.activate()
