class_name HandState_Grab_Item
extends HandState

var testing_throw_alt: bool = false
# ↑ A/B TESTING Stuff ↑
# -

var is_ready: bool
var is_exiting: bool

var tween: Tween

@export var offset_helper: Control
var offset_og_pos: Vector2

var current_grab_prompt: String
var current_hand_prompt: String

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if is_exiting: return
	
	set_grab_position()
	
	if Input.is_action_just_pressed("testing_altthrow"): testing_throw_alt = !testing_throw_alt
	
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if is_ready:
		if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type):
			begin_charge()
	if Input.is_action_pressed("action_" + hand_controller.stringed_hand_type):
			charging(_delta)
	if is_charging and Input.is_action_just_released("action_" + hand_controller.stringed_hand_type):
			end_charge()
	
	if !is_charging: item_receiver = hand_controller.interact_checker_item_receiver()
	if item_receiver and item_receiver.check_if_need_item(grabbed_item):
		if !hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = true
			hand_controller.input_controls.enable_use_action(item_receiver.prompt_text)
			hand_controller.anim_change_prompt_anim(item_receiver.hand_prompt)
	else:
		if hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = false
			if grabbed_item.item_type.item_type == ItemType.ItemTypes.INSTRUMENT: 
				print("d")
				hand_controller.input_controls.enable_use_action(grabbed_item.use_prompt)
			else: hand_controller.input_controls.disable_use_action()
			hand_controller.anim_change_prompt_anim(anim_prompt)
	
	if !is_charging and Input.is_action_just_pressed("use_" + hand_controller.stringed_hand_type):
		use()
	
	if !item_receiver and !is_charging and Input.is_action_pressed("use_" + hand_controller.stringed_hand_type):
		using()
	
	if !is_charging and !item_receiver and Input.is_action_just_released("use_" + hand_controller.stringed_hand_type):
		end_use()
	
	if is_ready:
		grabbing()

func physics_update(_delta: float) -> void:
	pass
	#if !item_receiver and Input.is_action_pressed("use_" + hand_controller.stringed_hand_type):
		#use()

func enter(previous_state_path: String, data := {}) -> void:
	grabbed_item = hand_controller.hovering_interactable
	grabbed_item.is_grabbed = true
	
	hand_controller.input_controls.enable_interact_action(tr("HOLD_TO_THROW"))
	
	offset_og_pos = offset_helper.position
	
	current_item_type = grabbed_item.item_type
	
	_space_state = hand_controller.cam.get_world_3d().direct_space_state
	
	player.current_weight += grabbed_item.get_weight()
	if player.current_pressureplate: player.current_pressureplate.update_weight_of_entity(player)
	# Animation
	hand_controller.anim_change_idle_anim(anim_idle)
	hand_controller.anim_change_prompt_anim(anim_prompt)
	
	hand_controller.anim_override_current_animation("a_hand_pickup", true)
	
	var item_rot_z: float = grabbed_item.grabbed_rotation
	if grabbed_item.use_grabbed_rotation_offsets and hand_controller.hand_type == 0: item_rot_z = grabbed_item.grabbed_rotation_left
	
	if hand_controller.hand_type == 0: 
		if grabbed_item.use_alt_flipping: item_rot_z *= 0.25
		else: item_rot_z *= -1
	
	#var new_rot: Quaternion = Quaternion.from_euler(Vector3(0, player.global_rotation.y, item_rot_z))
	var new_rot: Vector3 = Vector3(0.0, player.global_rotation.y, item_rot_z)
	set_grab_position()
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(grabbed_item, "global_position", grab_position, 0.075)
	tween.tween_property(grabbed_item, "global_rotation", new_rot, 0.1)
	
	await tween.finished
	grabbed_item.global_rotation = new_rot
	
	if grabbed_item.item_type.item_type == ItemType.ItemTypes.INSTRUMENT: 
		print("d")
		hand_controller.input_controls.enable_use_action(grabbed_item.use_prompt)
	
	is_ready = true
	time_held_down = 0
	
	if grabbed_item.no_screen_restrictions: hand_controller.test_handlimit = false

func exit() -> void:
	player.current_weight -= grabbed_item.get_weight()
	if player.current_pressureplate: player.current_pressureplate.update_weight_of_entity(player)
	hand_controller.hovering_interactable = null
	is_ready = false
	tween.kill()
	is_charging = false
	charge_amount = 0
	time_held_down = 0
	offset_helper.position = offset_og_pos
	hand_controller.input_controls.disable_interact_action()
	t_bob = 0.0
	hand_controller.test_handlimit = true
	#is_exiting = true
	#grabbed_item = null

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

const GRAB_DIST = 1.0
var grabbed_item: Grabbable_Item
var grab_position: Vector3
@export_flags_2d_physics var grab_ray_collision_mask: int

var item_at_edge_of_screen: bool

var _space_state: PhysicsDirectSpaceState3D

var is_against_wall: bool

func set_grab_position() -> void:
	var _grab_pos: Vector2
	if is_charging:  
		if grabbed_item.use_grabbed_individual_offsets and hand_controller.hand_type == 0:
			_grab_pos = Vector2(grabbed_item.grabbed_offset_left.x * hand_controller.hand_type_rotation_mult, grabbed_item.grabbed_offset_left.y)
		else:
			_grab_pos = Vector2(grabbed_item.throwing_offset.x * hand_controller.hand_type_rotation_mult, grabbed_item.throwing_offset.y)
	else:  
		if grabbed_item.use_grabbed_individual_offsets and hand_controller.hand_type == 0:
			_grab_pos = Vector2(grabbed_item.grabbed_offset_left.x * hand_controller.hand_type_rotation_mult, grabbed_item.grabbed_offset_left.y)
		else:
			_grab_pos = Vector2(grabbed_item.grabbed_offset.x * hand_controller.hand_type_rotation_mult, grabbed_item.grabbed_offset.y)
	
	var origin := hand_controller.cam.project_ray_origin(offset_helper.get_screen_position() + _grab_pos)
	var end := origin + hand_controller.cam.project_ray_normal(offset_helper.global_position + _grab_pos) * GRAB_DIST
	
	var query := PhysicsRayQueryParameters3D.create(origin, end, grab_ray_collision_mask) # probably want to add layer stuff later
	query.collide_with_areas = true
	
	var result = _space_state.intersect_ray(query)
	
	if !result or !result.collider:
		grab_position = end
		is_against_wall = false
	else:
		is_against_wall = true
		grab_position = result.position + (result.normal * 0.1)

func grabbing() -> void:
	grabbed_item.global_position = grab_position
	grabbed_item.global_rotation.y = hand_controller.player.rotation.y
	#if grabbed_item is Torch:
		#if hand_controller.get_screen_position().x < player_interact.size.x * 0.2 or hand_controller.get_screen_position().x > player_interact.size.x * 0.8:
			#if !item_at_edge_of_screen:
				##grabbed_item.rotation_degrees.z = -5 * hand_controller.hand_type_rotation_mult
				#grabbed_item.rotation_degrees.z = -grabbed_item.throwing_rotation * hand_controller.hand_type_rotation_mult
				#item_at_edge_of_screen = true
				#hand_controller.anim_change_idle_anim("hand_torch_side")
		#else:
			#if item_at_edge_of_screen:
				#grabbed_item.rotation.z = grabbed_item.grabbed_rotation * hand_controller.hand_type_rotation_mult
				#item_at_edge_of_screen = false
				#hand_controller.anim_change_idle_anim(anim_idle)

# ↑ Grabbing Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Using Stuff ↓

var current_item_type: ItemType
var item_receiver: ItemReceiver

func use():
	if item_receiver and item_receiver.receive_item(grabbed_item):
		if item_receiver.destroy_items_on_receive:
			is_charging = false
			charge_amount = 0
			time_held_down = 0
			finished.emit(FREE)
	else:
		match current_item_type.item_type:
			ItemType.ItemTypes.DEFAULT:
				return # maybe an inspect?
			ItemType.ItemTypes.TORCH:
				return
			ItemType.ItemTypes.CONSUMABLE:
				return
			ItemType.ItemTypes.INSTRUMENT:
				pass
			_:
				return
	

func using()-> void:
	match current_item_type.item_type:
			ItemType.ItemTypes.DEFAULT:
				return # maybe an inspect?
			ItemType.ItemTypes.TORCH:
				return
			ItemType.ItemTypes.CONSUMABLE:
				return
			ItemType.ItemTypes.INSTRUMENT:
				var freq : int
				if !hand_controller.test_handlimit:
					freq = int(remap((hand_controller.get_screen_position().x+(hand_controller.size.x/2))/player_interact.size.x, 0, 1, 0, 7))
				else:
					freq = int(remap(hand_controller.get_screen_position().x, hand_controller.test_screen_limit_x_min, hand_controller.test_screen_limit_x_max - hand_controller.size.x, 0, 6))
				#print(freq)
				grabbed_item.using_item([freq])
			_:
				return

func end_use() -> void:
	if item_receiver and item_receiver.receive_item(grabbed_item): pass
	else:
		grabbed_item.end_using_item([])
		return

# ↑ Using Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Charging Stuff ↓

var is_charging: bool 
var charge_amount: float
@export var delay_before_max_charge := 2.0
var time_held_down: float = 0.0

var BOB_FREQ: float = 0.75
var BOB_AMP: float = 6.5
var t_bob: float = 0.0

var played_sfx: bool

func begin_charge() -> void:
	is_charging = true
	charge_amount = 0
	time_held_down = 0
	hand_controller.anim_override_current_animation("a_hand_grab_item_charge", true)
	hand_controller.anim_change_idle_anim("a_hand_grab_item_charge")
	grabbed_item.rotation_degrees.z = -grabbed_item.throwing_rotation * hand_controller.hand_type_rotation_mult
	hand_controller.input_controls.enable_interact_action(tr("RELEASE_TO_THROW"))
	

func charging(_delta: float) -> void:
	if !is_charging: return
	time_held_down += _delta
	var _charged_amount = time_held_down / delay_before_max_charge
	
	if !played_sfx and charge_amount >= 0.1:
		hand_controller.audio_throw.stream = player_interact.throw_clips[0] #AUDIO
		hand_controller.audio_throw.play() #AUDIO
		played_sfx = true
	
	charge_amount = clampf(_charged_amount, 0.0, 1.0)
	t_bob += _delta * charge_amount * 50
	if charge_amount > 0.1:
		t_bob += _delta * charge_amount * 50
		offset_helper.position = offset_og_pos + _headbob(t_bob)
		

func end_charge() -> void:
	hand_controller.anim_override_current_animation("a_hand_grab_item_charge", true)
	if charge_amount < 0.1 or is_against_wall: grabbed_item.end_interact()
	else: 
		if !testing_throw_alt:
			grabbed_item.throw(charge_amount)
			
			hand_controller.audio_throw.stream = player_interact.throw_clips[1] #AUDIO
			hand_controller.audio_throw.play() #AUDIO
		else:
			var origin := hand_controller.cam.project_ray_origin(player_interact.get_rect().get_center())
			var end := origin + hand_controller.cam.project_ray_normal(offset_helper.global_position) * GRAB_DIST
			var dir: Vector3 = origin.direction_to(end)
			grabbed_item.throw_alt(charge_amount, dir)
	
	grabbed_item.rotation.z = 0
	is_charging = false
	charge_amount = 0
	time_held_down = 0
	grabbed_item.is_grabbed = false
	played_sfx = false
	finished.emit(FREE)


func _headbob(time: float) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = sin(time * BOB_FREQ) * BOB_AMP
	pos.y = cos(time * BOB_FREQ/4) * BOB_AMP
	
	return pos

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓
