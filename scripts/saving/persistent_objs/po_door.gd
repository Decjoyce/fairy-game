@tool
class_name PO_Door
extends PersistentObject

@onready var parent_door: Door = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Door.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.opened = parent_door.opened
	if parent_door.anim_player.current_animation:
		my_data.cur_anim = parent_door.anim_player.current_animation
		my_data.anim_frame = parent_door.anim_player.current_animation_position
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Door:
		parent_door.opened = saved_data.opened
		if saved_data.cur_anim:
			parent_door.anim_player.play_section(saved_data.cur_anim, saved_data.anim_frame)
		elif parent_door.opened: parent_door.anim_player.play_section("door_open", 0.5, -1, -1, 50000)
