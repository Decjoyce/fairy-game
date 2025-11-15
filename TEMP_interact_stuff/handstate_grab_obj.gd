class_name HandState_Grab_Obj
extends HandState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type): finished.emit(FREE)
	
	if Input.is_action_just_pressed("turn_left") or Input.is_action_just_pressed("turn_right"): finished.emit(FREE)

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	setup()
	

func exit() -> void:
	grabbed_obj.on_end_interact()
	if !grabbed_obj.is_being_pulled:
		
		player_interact.movement.is_grabbing_object = false
		player_interact.movement.grabbed_obj = null
		
		grabbed_obj.reparent(get_tree().current_scene, true)
		#var new_pos = player.movement.compass.global_position - player.movement.compass.basis.z
		#grabbed_obj.global_position.z = new_pos.z
		#grabbed_obj.global_position.x = new_pos.x
		
		moving_breaks_free = true
		other_hand.state.moving_breaks_free = true
	grabbed_obj = null

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

var grabbed_obj: Grabbable_Obj # might change this to the actual grabbable_obj class instead of interactable

func setup():
	grabbed_obj = hand_controller.current_interactable
	moving_breaks_free = true
	if grabbed_obj.is_being_pulled:
		# Reparent to player and set its position ~ will be changed to some sort of lerped movement or something
		grabbed_obj.reparent(player, true)
		#var new_pos = player.movement.compass.global_position - player.movement.compass.basis.z
		#grabbed_obj.global_position.z = new_pos.z
		#grabbed_obj.global_position.x = new_pos.x
		#grabbed_obj.position.z -= 1
		var rounded_pos:= grabbed_obj.position.round()
		grabbed_obj.position = Vector3(rounded_pos.x, grabbed_obj.position.y, rounded_pos.z)
		
		# Tell movement that your grabbing obj ~ this probs will be changed too
		player_interact.movement.is_grabbing_object = true
		player_interact.movement.grabbed_obj = grabbed_obj
		
		# Stops player breaking out of grab state if they move
		moving_breaks_free = false
		other_hand.state.moving_breaks_free = false
