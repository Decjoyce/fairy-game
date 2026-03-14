@tool
class_name PO_MusicTrig
extends PersistentObject

@onready var parent_mt: MusicReceiver = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_MusicTrig.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.activated = parent_mt.activated
	my_data.current_melody = parent_mt.current_melody
	my_data.cur_note = parent_mt.cur_note
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_MusicTrig:
		parent_mt.activated = saved_data.activated
		parent_mt.current_melody = saved_data.current_melody
		parent_mt.cur_note = saved_data.cur_note
		if !parent_mt.activated:
			parent_mt.update_current_sequence()
			parent_mt.update_needed_note()
