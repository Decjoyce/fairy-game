@tool
class_name PO_AnimatedObject
extends PersistentObject

@onready var parent_ao: AnimatedObject = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_AnimatedObject.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.current_anim = parent_ao.anim_player.current_animation
	my_data.current_position = parent_ao.anim_player.current_animation_position
	my_data.end_pos = parent_ao.end_pos
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_AnimatedObject:
		#prints(saved_data.current_position, saved_data.end_pos)
		parent_ao.play_animation_to_position(saved_data.current_anim, saved_data.current_position, saved_data.end_pos)
		#prints(saved_data.current_position-0.1, parent_ao.anim_player.current_animation_position)
