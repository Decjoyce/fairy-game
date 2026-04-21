@tool
class_name PO_Ballybog
extends PersistentObject

@onready var parent_bb: Enemy_Ballybog_New = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Ballybog.new()
	my_data.uid = get_parent().get_meta("uid")
	# general
	my_data.current_pos = parent_bb.global_position
	my_data.current_rot = parent_bb.graphics.global_rotation
	my_data.current_awareness = parent_bb.current_alertness
	# movement
	my_data.current_destination = parent_bb.movement.current_destination
	my_data.current_grid_pos = parent_bb.movement.current_grid_pos
	my_data.current_path = parent_bb.movement.current_path
	# state
	my_data.current_state = parent_bb.state_machine.state.name
	my_data.time_left = parent_bb.state_machine.state.wait_timer.time_left
	## patrol
	my_data.patrol_current_patrol_point = parent_bb.get_node("%PATROL").current_patrol_point
	## investigate
	var inv_state: EnemyState_Investigate = parent_bb.get_node("%INVESTIGATE")
	my_data.inv_current_investigate_state = inv_state.current_investigate_state
	my_data.inv_giveup_timeleft = inv_state.giveup_timer.time_left
	## chase
	var chase_state: EnemyState_Chase = parent_bb.get_node("%CHASE")
	my_data.chase_failsafe_timeleft = chase_state.failsafe_timer.time_left
	my_data.chase_last_known_loc = chase_state.last_known_location
	my_data.chase_has_reacted = chase_state.has_reacted
	my_data.chase_lost_player = chase_state.lost_player
	## stun
	my_data.stun_item_dropped_pos = parent_bb.get_node("%STUNNED").item_dropped_pos
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	parent_bb.movement.stop_movement()

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Ballybog:
		print("f")
		parent_bb.global_position = saved_data.current_pos
		parent_bb.graphics.global_rotation = saved_data.current_rot
		parent_bb.current_alertness = saved_data.current_awareness
		# State
		parent_bb.state_machine.load_states(saved_data)
