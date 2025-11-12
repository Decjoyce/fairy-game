class_name PlayerHand
extends Control

enum HandTypes {LEFT, RIGHT}
@export var hand_type : HandTypes
@onready var stringed_hand_type: String = HandTypes.find_key(hand_type)

@onready var interact: PlayerInteract = get_parent()

@onready var hand_sprite: TextureRect = $_hand_sprite

var hovering_interactable: Interactable
var current_interactable: Interactable
var grabbed_obj: Interactable

const min_speed: float = 500
const max_speed: float = 1000
@onready var current_speed: float = min_speed

@export var initial_state: HandState = null

@onready var state: HandState = (func get_initial_state() -> HandState: return initial_state if initial_state != null else get_child(0)).call()

func _ready() -> void:
	for state_node: HandState in get_child(0).find_children("*", "HandState"):
		state_node.finished.connect(_transition_to_next_state)
		
		await owner.ready
		state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if !has_node(target_state_path):
		printerr(owner.name + ": Tring to transition to state " + target_state_path + " but it does not exist.")
		return
	
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

# ↑ State Stuff ↑
# ----------------------------------------------------------------------------------
# ↓ Non State Stuff ↓

func joystick_movement(delta: float) -> void:
	var motion := Input.get_vector(stringed_hand_type + "_joystick_left", stringed_hand_type + "_joystick_right", stringed_hand_type + "_joystick_down", stringed_hand_type + "_joystick_up")
	
	move_hand(motion, delta)

func move_hand(dir: Vector2, delta: float) -> void:
	position += Vector2(dir.x, -dir.y) * current_speed * delta
	position.x = clampf(position.x, 0, interact.size.x - size.x)
	position.y = clampf(position.y, 0, interact.size.y - size.y)

func change_hand_speed() -> void:
	if current_speed == min_speed: current_speed = max_speed
	elif current_speed == max_speed: current_speed = min_speed

func interact_checker(): # -> Interactable:
	var space_state = interact.cam.get_world_3d().direct_space_state
	
	var origin = interact.cam.project_ray_origin(get_screen_position() + size/2)
	var end = origin + interact.cam.project_ray_normal(position + size/2) * interact.INT_RAY_LENGTH
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider or result.collider is not Interactable:
		return null
	
	return result.collider as Interactable
