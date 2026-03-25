@tool
class_name PO_Item
extends PersistentObject

@onready var parent_item: Grabbable_Item = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	if Engine.is_editor_hint(): return
	if parent_item.starting_pos == parent_item.global_position: 
		#prints(parent_item.name, "i didnt save bc sp == gp")
		return
	if parent_item.non_scene_native and parent_item.is_pooled: 
		#prints(parent_item.name, "i didnt save bc either; non_scene_native ==", parent_item.non_scene_native, "; or; is_pooled ==", parent_item.is_pooled)
		return
	
	var my_data := SavedDataItem.new()
	if parent_item.non_scene_native:
		my_data.scene_path = parent_item.scene_file_path
		my_data.uid = "[NONNATIVE]"
	else:
		assert(parent_item.has_meta("uid"), "ERROR: Could not find UID on - " + parent_item.name + " - please generate UIDs")
		assert(parent_item.get_meta("uid") != "", "ERROR: Invalid UID found on - " + parent_item.name + " - please generate UIDs")
		my_data.uid = parent_item.get_meta("uid")
	my_data.non_scene_native = parent_item.non_scene_native
	my_data.is_pooled = parent_item.is_pooled
	my_data.position = parent_item.global_position
	my_data.velocity = parent_item.rb.linear_velocity
	my_data.rotation = parent_item.global_rotation
	my_data.is_broken = parent_item.is_broken
	my_data.is_grabbed = parent_item.is_grabbed
	my_data.has_been_picked_up = parent_item.has_been_picked_up
	my_data.prev_velocity = parent_item.prev_velocity
	
	#print(my_data.has_been_spawned)
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedDataItem:
		#print(saved_data)
		if saved_data.non_scene_native and saved_data.is_pooled: 
			print("kill me")
			queue_free()
		parent_item.global_position = saved_data.position
		parent_item.global_rotation = saved_data.rotation
		parent_item.rb.linear_velocity = saved_data.velocity
		parent_item.prev_velocity = saved_data.prev_velocity
		parent_item.non_scene_native = saved_data.non_scene_native
		parent_item.has_been_picked_up = saved_data.has_been_picked_up
		if parent_item.is_broken: parent_item.break_item()
