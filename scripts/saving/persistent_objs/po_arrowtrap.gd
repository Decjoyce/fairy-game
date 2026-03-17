@tool
class_name PO_ArrowTrap
extends PersistentObject

@onready var parent_tp: TrapProj = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	var shot_arrow: ArrowProjectiles
	for i in parent_tp.projectile_pool:
		if i.shot:
			shot_arrow = i
			break
	if !shot_arrow: return
	
	var my_data := SavedData_TrapProj.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.arrow_pos = shot_arrow.global_position
	my_data.arrow_dir = shot_arrow.dir
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_TrapProj:
		parent_tp.projectile_pool[0].global_position = saved_data.arrow_pos
		parent_tp.projectile_pool[0].dir = saved_data.arrow_dir
		parent_tp.projectile_pool[0].shoot(false)
