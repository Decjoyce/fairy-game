class_name PlayerInteract
extends Control

@export var movement: PlayerMovement

@export var cam: Camera3D
const INT_RAY_LENGTH = 1.5
@export_flags_2d_physics var interaction_collision_mask: int
@export_flags_2d_physics var item_receiver_collision_mask: int
@export_flags_2d_physics var enemy_collision_mask: int

@export var hand_left: PlayerHand # index = 0
@export var hand_right: PlayerHand # index = 1
@export var hand_left_sprite: TextureRect
@export var hand_right_sprite: TextureRect

@export var light_checker: LightChecker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	movement.on_move.connect(hand_left.on_player_moved)
	movement.on_move.connect(hand_right.on_player_moved)
	movement.on_turn.connect(hand_left.on_player_turned)
	movement.on_turn.connect(hand_right.on_player_turned)
	movement.on_crouch.connect(hand_left.on_player_crouched)
	movement.on_crouch.connect(hand_right.on_player_crouched)

@onready var load_game_graphics: TextureProgressBar = $Control/TextureRect/TextureProgressBar
var is_reloading: bool
var load_level_thing: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match_hand_to_light(delta)
	
	if Input.is_action_just_pressed("reload_level"): 
		load_level_thing = 0
		load_game_graphics.get_parent().visible = true
		is_reloading = true
	
	if is_reloading and Input.is_action_pressed("reload_level"): 
		load_level_thing+= delta
		load_game_graphics.value = load_level_thing/5
		if load_level_thing >= 5:
			TEMPSaveGameHandler.load_game()
	
	if Input.is_action_just_released("reload_level"): 
		load_level_thing = 0
		load_game_graphics.get_parent().visible = false
		is_reloading = false

func make_hands_inactive() -> void:
	hand_left.state.finished.emit(hand_left.state.FREE)
	hand_right.state.finished.emit(hand_left.state.FREE)
	if hand_left.current_interactable: hand_left.current_interactable.end_interact()
	if hand_right.current_interactable: hand_right.current_interactable.end_interact()

func get_other_hand(hand_index: int) -> PlayerHand:
	if hand_index == 0: return hand_right
	else: return hand_left

func get_other_hand_state(hand_index: int) -> HandState:
	if hand_index == 0: return hand_right.state
	else: return hand_left.state

func get_other_hand_current_interactable(hand_index: int) -> Interactable:
	if hand_index == 0: return hand_right.current_interactable
	else: return hand_left.current_interactable

func force_stop_interacting(next_state: String = "FREE", call_end_func_on_interactable: bool = true, call_end_func_on_state: bool = true) -> void:
	hand_right.force_stop_interacting(next_state, call_end_func_on_interactable, call_end_func_on_state)
	hand_left.force_stop_interacting(next_state, call_end_func_on_interactable, call_end_func_on_state)

func free_interaction_on_other_hand(hand_index: int) -> void:
	if hand_index == 0: hand_right.force_stop_interacting()
	elif hand_index == 1: hand_left.force_stop_interacting()

func test_player_moved()-> void:
	hand_right.on_player_moved(Vector3.ZERO, Vector3.ZERO)
	hand_left.on_player_moved(Vector3.ZERO, Vector3.ZERO)
	

#const NO_LIGHT_COLOR: Color = Color("20415e")
#@export var hand_light_gradient: Gradient

func match_hand_to_light(_delta: float) -> void:
	
	if TEMPSaveGameHandler.experimental_handlighting:
		hand_left_sprite.self_modulate = light_checker.lerped_current_light_avgcolor
		hand_right_sprite.self_modulate = light_checker.lerped_current_light_avgcolor
	else:
		hand_left_sprite.self_modulate = Color.WHITE
		hand_right_sprite.self_modulate = Color.WHITE
	#var mapped_light_level := remap(light_checker.lerped_current_light, 0.35, 1, 0, 1)
	#hand_right_sprite.self_modulate = hand_light_gradient.sample(mapped_light_level)
	##hand_right_sprite.self_modulate = hand_right_sprite.self_modulate.blend(light_checker.lerped_current_light_avgcolor).lightened(0.5)
	#print(light_checker.lerped_current_light)


@export_group("AUDIO") #AUDIO
@export var throw_clips: Array[AudioStream] ## 0 = charge, 1 = release
