@tool
class_name PO_ItmReceiver
extends PersistentObject

@onready var parent_ir: ItemReceiver = get_parent()


func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_ItmReceiver.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.disabled = parent_ir.disabled
	my_data.is_activated = parent_ir.is_activated
	if !parent_ir.is_activated:
		match parent_ir.receiver_type:
			0: # Type
				my_data.num_have_by_type = parent_ir.num_have_by_type
			1: # Keyword
				my_data.num_have_by_keyword = parent_ir.num_have_by_keyword
			2: # Specific
				for i in parent_ir.spec_needed_items_received:
					assert(i.has_meta("uid"), "Missing UID on - " + i.name)
					my_data.spec_needed_items_received.append(i.get_meta("uid"))
			3: # EITHER
				my_data.num_have_by_type = parent_ir.num_have_by_type
				my_data.num_have_by_keyword = parent_ir.num_have_by_keyword
				for i in parent_ir.spec_needed_items_received:
					assert(i.has_meta("uid"), "Missing UID on - " + i.name)
					my_data.spec_needed_items_received.append(i.get_meta("uid"))
			4: # Any 
				my_data.num_have_for_any = parent_ir.num_have_for_any
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_ItmReceiver:
		parent_ir.disabled = saved_data.disabled
		parent_ir.is_activated = saved_data.is_activated
		if !saved_data.is_activated:
			match parent_ir.receiver_type:
				0: # Type
					parent_ir.num_have_by_type = saved_data.num_have_by_type
				1: # Keyword
					parent_ir.num_have_by_keyword = saved_data.num_have_by_keyword
				2: # Specific
					for i in saved_data.spec_needed_items_received:
						assert(TEMPSaveGameHandler.uid_list.has(i), "Item's UID was saved but cannot be found in scene" + i)
						parent_ir.spec_needed_items_received.append(TEMPSaveGameHandler.uid_list[i].get_parent())
						parent_ir.needed_items_left.erase(TEMPSaveGameHandler.uid_list[i].get_parent())
				3: # EITHER
					parent_ir.num_have_by_type = saved_data.num_have_by_type
					parent_ir.num_have_by_keyword = saved_data.num_have_by_keyword
					for i in saved_data.spec_needed_items_received:
						assert(TEMPSaveGameHandler.uid_list.has(i), "Item's UID was saved but cannot be found in scene" + i)
						parent_ir.spec_needed_items_received.append(TEMPSaveGameHandler.uid_list[i].get_parent())
						parent_ir.needed_items_left.erase(TEMPSaveGameHandler.uid_list[i].get_parent())
				4: # Any 
					parent_ir.num_have_for_any = saved_data.num_have_for_any
