class_name PlayerHand
extends Control

var test_handlimit: bool = true
var test_screen_limit_x_min: float 
var test_screen_limit_x_max: float 
var test_screen_fraction: float = 5.0


func calc_limit() -> void:
	if hand_type == HandTypes.LEFT:
		test_screen_limit_x_min = 0
		test_screen_limit_x_max = (player_interact.size.x - (player_interact.size.x/test_screen_fraction)) - size.x
	else:
		test_screen_limit_x_min = player_interact.size.x/test_screen_fraction
		test_screen_limit_x_max = player_interact.size.x - size.x

# ↑ A/B TESTING Stuff ↑
# --------------------------------------------------------------------------------------------------

@onready var player: PlayerTest = get_parent().get_parent()
@onready var player_interact: PlayerInteract = get_parent()
var cam: Camera3D

enum HandTypes {LEFT, RIGHT}
@export var hand_type : HandTypes
@onready var stringed_hand_type: String = HandTypes.find_key(hand_type)
@onready var hand_type_rotation_mult: int = 1

@onready var hand_sprite: TextureRect = $_hand_sprite

@onready var input_controls: InputContexts = $_hand_sprite/InputContexts

func _ready() -> void:
	#animation_player.animation_finished.connect(play_queued_animation)
	if hand_type == 0: hand_type_rotation_mult = -1
	else: hand_type_rotation_mult = 1
	
	_init_states()

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ State Stuff ↓

@export var initial_state: HandState = null
@onready var state: HandState = (func get_initial_state() -> HandState: return initial_state if initial_state != null else get_child(0)).call()

func _init_states() -> void:
	for state_node: HandState in get_child(0).find_children("*", "HandState"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.enter("")
	cam = player_interact.cam

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	#if player.in_combat: return
	if Input.is_action_just_pressed("testing_handlimit"):
		test_handlimit = !test_handlimit
	if Input.is_action_just_pressed("testing_handlimit_change"):
		if test_screen_fraction == 3.0: test_screen_fraction = 5.0
		elif test_screen_fraction == 5.0: test_screen_fraction = 3.0
	state.update(delta)

func _physics_process(delta: float) -> void:
	if player.in_combat: return
	state.physics_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if !get_child(0).has_node(target_state_path):
		printerr(owner.name + ": Tring to transition to state " + target_state_path + " but it does not exist.")
		return
	
	var previous_state_path := state.name
	state.exit()
	state = get_child(0).get_node(target_state_path)
	state.enter(previous_state_path, data)

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Hand Stuff ↓

const min_speed: float = 750
const mid_speed: float = 1000
const max_speed: float = 2000
var cur_speed_index: int = 2
@onready var current_speed: float = max_speed

func joystick_movement(delta: float) -> void:
	var motion := Input.get_vector(stringed_hand_type + "_joystick_left", stringed_hand_type + "_joystick_right", stringed_hand_type + "_joystick_down", stringed_hand_type + "_joystick_up")
	
	move_hand(motion, delta)

func move_hand(dir: Vector2, delta: float) -> void:
	position += Vector2(dir.x, -dir.y) * current_speed * delta
	
	if !test_handlimit: ## ----- [-] TESTING A/B
		position.x = clampf(position.x, 0, player_interact.size.x - size.x)
	else:
		calc_limit()
		position.x = clampf(position.x, test_screen_limit_x_min, test_screen_limit_x_max)
	
	position.y = clampf(position.y, 0, player_interact.size.y - size.y * 1.4)

func change_hand_speed() -> void:
	cur_speed_index = wrapi(cur_speed_index+1, 0, 3)
	match cur_speed_index:
		0: current_speed = min_speed
		1: current_speed = mid_speed
		2: current_speed = max_speed

# ↑ Hand Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Interacting Stuff ↓

signal on_hovering_interactable_change(_new_interactable: Interactable)
var hovering_interactable: Interactable
var current_interactable: Interactable = null
var grabbed_obj: Interactable

func begin_interact() -> void:
	if !hovering_interactable:
		return
	if (hovering_interactable.interaction_type == hovering_interactable.InteractTypes.LEVER or hovering_interactable.interaction_type == hovering_interactable.InteractTypes.TEMP_SAVE) and player.movement.dist_to_target >= 0.6: 
		return
	if hovering_interactable.interaction_type == hovering_interactable.InteractTypes.TEMP_SAVE and player.movement.dist_to_target >= 0.3:
		return
	anim_is_prompting = false
	current_interactable = hovering_interactable
	#current_interactable.begin_interact()
	match hovering_interactable.interaction_type:
		hovering_interactable.InteractTypes.INSTANT:
			if animation_player.has_animation(current_interactable.interact_animation):
				current_interactable.begin_interact()
				anim_override_current_animation(current_interactable.interact_animation)
			
		hovering_interactable.InteractTypes.GRAB_ITEM:
			if player_interact.get_other_hand_state(hand_type) is HandState_Grab_Item:
				if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
					player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			current_interactable.begin_interact(-1.0, self)
			state.finished.emit(state.GRAB_ITEM)
			audio_grab.play()
		hovering_interactable.InteractTypes.GRAB_OBJ:
			current_interactable.begin_interact()
			state.finished.emit(state.GRAB_OBJ)
			pass
			
		hovering_interactable.InteractTypes.LEVER:
			if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
					player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			current_interactable.begin_interact()
			state.finished.emit(state.LEVER)
		hovering_interactable.InteractTypes.TEMP_KEYHOLE:
			if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
				player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			current_interactable.begin_interact()
			state.finished.emit(state.KEY)
		hovering_interactable.InteractTypes.TEMP_CHAIN:
			if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
				player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			current_interactable.begin_interact()
			state.finished.emit(state.CHAIN)
		hovering_interactable.InteractTypes.TEMP_VALVE:
			if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
				player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			current_interactable.begin_interact()
			state.finished.emit(state.VALVE)
		hovering_interactable.InteractTypes.TEMP_SAVE:
			current_interactable.begin_interact()
			state.finished.emit(state.SAVING)

func on_player_moved(direction: Vector3, target: Vector3) -> void:
	if !state.moving_breaks_free:
		return
	force_stop_interacting()

func on_player_turned(target_rot: float) -> void:
	if !state.turning_breaks_free:
		return
	force_stop_interacting()

func on_player_crouched(crouched: bool) -> void:
	if !state.crouching_breaks_free:
		return
	force_stop_interacting()

func force_stop_interacting(next_state: String = "FREE", call_end_func_on_interactable: bool = true, call_end_func_on_state: bool = true) -> void:
	if call_end_func_on_state: state.finished.emit(next_state)
	if current_interactable and call_end_func_on_interactable: current_interactable.end_interact()
	current_interactable = null

func interact_checker(): # -> Interactable:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(get_screen_position() + size/2)
	var end = origin + cam.project_ray_normal(position + size/2) * player_interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, player_interact.interaction_collision_mask)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result: #!result.collider or result.collider.get_parent() is not Interactable:
		return null
	elif !result.collider: 
		return null
	elif result.collider.get_parent() is not Interactable: 
		#prints("NOTACCEPTED", result.collider, result.collider.get_parent())
		return null
	
	var _interactable: Interactable = result.collider.get_parent() as Interactable
	
	if _interactable.disabled: return null
	
	return _interactable

func interact_checker_item_receiver(): # -> Interactable:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(get_screen_position() + size/2)
	var end = origin + cam.project_ray_normal(position + size/2) * player_interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, player_interact.item_receiver_collision_mask)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider or result.collider.get_parent() is not ItemReceiver:
		return null
	
	var _interactable: ItemReceiver = result.collider.get_parent() as ItemReceiver
	
	if _interactable.disabled: return null
	
	return _interactable

func interact_checker_enemy(): # -> Interactable:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(get_screen_position() + size/2)
	var end = origin + cam.project_ray_normal(position + size/2) * player_interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, player_interact.enemy_collision_mask)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider or result.collider.get_parent() is not Enemy_Ballybog_New:
		return null
	
	var _enemy: Enemy_Ballybog_New = result.collider.get_parent() as Enemy_Ballybog_New
	
	
	return _enemy

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Animating Stuff ↓

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var anim_is_overriding: bool
var anim_override_animation: String

var anim_is_prompting: bool
var anim_prompting_animation: String
@export var anim_prompting_default: String

var anim_idle_animation: String
@export var anim_idle_default: String

func anim_change_idle_anim(_new_anim: String, update_anims: bool = true) -> void:
	if _new_anim == "" or !animation_player.has_animation(_new_anim): 
		anim_idle_animation = anim_idle_default
		printerr(_new_anim + " - this idle animation cannot be found under - " + name)
		return
	anim_idle_animation = _new_anim
	if update_anims: anim_update_animations()

func anim_change_prompt_anim(_new_anim: String, update_anims: bool = true) -> void:
	if _new_anim == "" or !animation_player.has_animation(_new_anim): 
		anim_prompting_animation = anim_prompting_default
		printerr(_new_anim + " - this prompt animation cannot be found under - " + name)
		return
	anim_prompting_animation = _new_anim
	if update_anims: anim_update_animations()

func anim_update_animations() -> void:
	var times_visited_this_frame: int
	var strdsd: String = ""
	if anim_is_overriding: return
	elif !anim_is_overriding and anim_is_prompting:
		if animation_player.current_animation == anim_prompting_animation: return
		animation_player.play(anim_prompting_animation, -1, 0.5)
	else:
		if animation_player.current_animation == anim_idle_animation: return
		animation_player.play(anim_idle_animation, -1, 0.5)
		

func anim_override_current_animation(_new_anim: String, restart_if_performing_anim_already: bool = false) -> void:
	if _new_anim == "" or !animation_player.has_animation(_new_anim): return
	if !restart_if_performing_anim_already and animation_player.current_animation == anim_override_animation: return
	anim_is_overriding = true
	animation_player.stop()
	animation_player.play(_new_anim)
	animation_player.animation_finished.connect(_on_anim_override_finished)
	anim_override_animation = _new_anim
 
func _on_anim_override_finished(_anim_name: String) -> void:
	anim_is_overriding = false
	animation_player.animation_finished.disconnect(_on_anim_override_finished)
	anim_update_animations()

# ↑ Animating Stuff ↑
# --------------------------------------------------------------------------------------------------

func force_grab_item(itm: Grabbable_Item) -> void:
	itm = current_interactable
	if player_interact.get_other_hand_state(hand_type) is HandState_Grab_Item:
		if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
			player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
	current_interactable.begin_interact()
	state.finished.emit(state.GRAB_ITEM)

@export_group("AUDIO")
@onready var audio_throw: AudioStreamPlayer = $Audio_Throw #AUDIO
@onready var audio_grab: AudioStreamPlayer = $Audio_Grab #AUDIO
