class_name PlayerInteract
extends Control

@export var movement: PlayerMovement

@export var cam: Camera3D
const INT_RAY_LENGTH = 2.0
@export_flags_2d_physics var interaction_collision_mask: int
@export_flags_2d_physics var item_receiver_collision_mask: int
@export_flags_2d_physics var enemy_collision_mask: int

@export var hand_left: PlayerHand # index = 0
@export var hand_right: PlayerHand # index = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement.on_move.connect(hand_left.on_player_moved)
	movement.on_move.connect(hand_right.on_player_moved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_other_hand(hand_index: int) -> PlayerHand:
	if hand_index == 0: return hand_right
	else: return hand_left

func get_other_hand_state(hand_index: int) -> HandState:
	if hand_index == 0: return hand_right.state
	else: return hand_left.state

func get_other_hand_current_interactable(hand_index: int) -> Interactable:
	if hand_index == 0: return hand_right.current_interactable
	else: return hand_left.current_interactable

func free_interaction_on_other_hand(hand_index: int) -> void:
	if hand_index == 0: hand_right.force_stop_interacting()
	elif hand_index == 1: hand_left.force_stop_interacting()
