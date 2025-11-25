class_name HandState_Grab_Item
extends HandState

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
	if item_receiver: 
		if !hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = true
			hand_controller.input_controls.enable_use_action(item_receiver.prompt_text)
			hand_controller.anim_change_prompt_anim(item_receiver.hand_prompt)
	else:
		if hand_controller.anim_is_prompting:
			hand_controller.anim_is_prompting = false
			hand_controller.input_controls.disable_use_action()
			hand_controller.anim_change_prompt_anim(anim_prompt)
	
	if !is_charging and Input.is_action_just_pressed("use_" + hand_controller.stringed_hand_type):
		use()
	
	if is_ready:
		grabbing()

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	grabbed_item = hand_controller.hovering_interactable
	
	hand_controller.input_controls.enable_interact_action("Hold to Throw")
	
	offset_og_pos = offset_helper.position
	
	current_item_type = grabbed_item.item_type
	
	_space_state = hand_controller.cam.get_world_3d().direct_space_state
	
	# Animation
	hand_controller.anim_change_idle_anim(anim_idle)
	hand_controller.anim_change_prompt_anim(anim_prompt)
	
	hand_controller.anim_override_current_animation("a_hand_pickup", true)
	
	var item_rot_z: float = grabbed_item.grabbed_rotation
	if hand_controller.hand_type == 0: item_rot_z *= -1
	
	var new_rot: Quaternion = Quaternion.from_euler(Vector3(0, player.rotation.y, item_rot_z))
	#player.quaternion
	set_grab_position()
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(grabbed_item, "global_position", grab_position, 0.075)
	tween.tween_property(grabbed_item, "quaternion", new_rot, 0.1)
	
	await tween.finished
	is_ready = true
	time_held_down = 0

func exit() -> void:
	hand_controller.hovering_interactable = null
	is_ready = false
	tween.kill()
	is_charging = false
	charge_amount = 0
	time_held_down = 0
	offset_helper.position = offset_og_pos
	hand_controller.input_controls.disable_interact_action()
	#is_exiting = true
	#grabbed_item = null

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

const GRAB_DIST = 0.9
var grabbed_item: Grabbable_Item
var grab_position: Vector3
@export_flags_2d_physics var grab_ray_collision_mask: int

var item_at_edge_of_screen: bool

var _space_state: PhysicsDirectSpaceState3D

func set_grab_position() -> void:
	var _grab_pos: Vector2
	if is_charging:  _grab_pos = Vector2(grabbed_item.throwing_offset.x * hand_controller.hand_type_rotation_mult, grabbed_item.throwing_offset.y)
	else:  _grab_pos = Vector2(grabbed_item.grabbed_offset.x * hand_controller.hand_type_rotation_mult, grabbed_item.grabbed_offset.y)
	
	var origin := hand_controller.cam.project_ray_origin(offset_helper.get_screen_position() + _grab_pos)
	var end := origin + hand_controller.cam.project_ray_normal(offset_helper.global_position + _grab_pos) * GRAB_DIST
	
	var query := PhysicsRayQueryParameters3D.create(origin, end, grab_ray_collision_mask) # probably want to add layer stuff later
	query.collide_with_areas = true
	
	var result = _space_state.intersect_ray(query)
	
	if !result or !result.collider:
		grab_position = end
	else:
		#print(result.collider)
		grab_position = result.position + (result.normal * 0.1)

func grabbing() -> void:
	grabbed_item.global_position = grab_position
	grabbed_item.rotation.y = hand_controller.player.rotation.y
	#if grabbed_item is Torch:
		#if hand_controller.get_screen_position().x < player_interact.size.x * 0.2 or hand_controller.get_screen_position().x > player_interact.size.x * 0.8:
			#if !item_at_edge_of_screen:
				#grabbed_item.rotation_degrees.z = -5 * hand_controller.hand_type_rotation_mult
				#item_at_edge_of_screen = true
				#hand_controller.anim_change_idle_anim("hand_prompt_lever")
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
				print("eat me")
	

# ↑ Using Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Charging Stuff ↓

var is_charging: bool 
var charge_amount: float
@export var delay_before_max_charge := 2.0
var time_held_down: float = 0.0

@export var BOB_FREQ: float
@export var BOB_AMP: float
var t_bob: float = 0.0

func begin_charge() -> void:
	is_charging = true
	charge_amount = 0
	time_held_down = 0
	hand_controller.anim_override_current_animation("a_hand_grab_item_charge", true)
	hand_controller.anim_change_idle_anim("a_hand_grab_item_charge")
	grabbed_item.rotation_degrees.z = -grabbed_item.throwing_rotation * hand_controller.hand_type_rotation_mult
	hand_controller.input_controls.enable_interact_action("Release to Throw")
	
func charging(_delta: float) -> void:
	if !is_charging: return
	time_held_down += _delta
	var _charged_amount = time_held_down / delay_before_max_charge
	
	charge_amount = clampf(_charged_amount, 0.0, 1.0)
	#t_bob += _delta * charge_amount * 50
	if charge_amount > 0.1:
		t_bob += _delta * charge_amount * 50
		#offset_helper.position = offset_og_pos + _headbob(t_bob)

func end_charge() -> void:
	hand_controller.anim_override_current_animation("a_hand_grab_item_charge", true)
	if charge_amount < 0.1: grabbed_item.end_interact()
	else: 
		grabbed_item.throw(charge_amount)
	
	grabbed_item.rotation.z = 0
	is_charging = false
	charge_amount = 0
	time_held_down = 0
	
	finished.emit(FREE)

func _headbob(time: float) -> Vector2:
	var pos = Vector2.ZERO
	pos.x = sin(time * BOB_FREQ) * BOB_AMP
	pos.y = cos(time * BOB_FREQ/4) * BOB_AMP
	
	return pos

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓
