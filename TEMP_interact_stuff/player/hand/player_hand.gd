class_name PlayerHand
extends Control

@onready var player: Node3D = get_parent().get_parent()
@onready var player_interact: PlayerInteract = get_parent()
var cam: Camera3D

enum HandTypes {LEFT, RIGHT}
@export var hand_type : HandTypes
@onready var stringed_hand_type: String = HandTypes.find_key(hand_type)

@onready var hand_sprite: TextureRect = $_hand_sprite

func _ready() -> void:
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
	state.update(delta)

func _physics_process(delta: float) -> void:
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

const min_speed: float = 500
const mid_speed: float = 1000
const max_speed: float = 1500
var cur_speed_index: int = 0
@onready var current_speed: float = min_speed

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func joystick_movement(delta: float) -> void:
	var motion := Input.get_vector(stringed_hand_type + "_joystick_left", stringed_hand_type + "_joystick_right", stringed_hand_type + "_joystick_down", stringed_hand_type + "_joystick_up")
	
	move_hand(motion, delta)

func move_hand(dir: Vector2, delta: float) -> void:
	position += Vector2(dir.x, -dir.y) * current_speed * delta
	position.x = clampf(position.x, 0, player_interact.size.x - size.x)
	position.y = clampf(position.y, 0, player_interact.size.y - size.y)

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
	current_interactable = hovering_interactable
	current_interactable.begin_interact()
	match hovering_interactable.interaction_type:
		hovering_interactable.InteractTypes.INSTANT:
			pass
			
		hovering_interactable.InteractTypes.GRAB_ITEM:
			if player_interact.get_other_hand_state(hand_type) is HandState_Grab_Item:
				if player_interact.get_other_hand_current_interactable(hand_type) == current_interactable:
					player_interact.free_interaction_on_other_hand(hand_type) # replace with signal
			
			state.finished.emit(state.GRAB_ITEM)
			
		hovering_interactable.InteractTypes.GRAB_OBJ:
			state.finished.emit(state.GRAB_OBJ)
			pass
			
		hovering_interactable.InteractTypes.LEVER:
			pass

func on_player_moved(direction: Vector3, target: Vector3) -> void:
	if !state.moving_breaks_free:
		return
	force_stop_interacting()

func force_stop_interacting(next_state: String = "FREE", call_end_func_on_interactable: bool = true, call_end_func_on_state: bool = true) -> void:
	state.finished.emit(next_state)
	current_interactable = null

func interact_checker(): # -> Interactable:
	var space_state = cam.get_world_3d().direct_space_state
	
	var origin = cam.project_ray_origin(get_screen_position() + size/2)
	var end = origin + cam.project_ray_normal(position + size/2) * player_interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end, player_interact.interaction_collision_mask)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider or result.collider.get_parent() is not Interactable:
		if animation_player.current_animation != "a_hand_idle":
			animation_player.play("a_hand_idle")
		return null
	
	var _interactable: Interactable = result.collider.get_parent() as Interactable
	
	if _interactable and _interactable != hovering_interactable:
		animation_player.play("a_hand_prompt")
	
	return _interactable

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
