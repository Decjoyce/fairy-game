class_name HandState
extends Node

const FREE = "FREE"
const CHALK = "CHALK"
const GRAB_ITEM = "GRAB_ITEM"
const GRAB_OBJ = "GRAB_OBJ"
const LEVER = "LEVER"
const ATTACK = "ATTACK"
const KEY = "KEY"
const CHAIN = "CHAIN"
const VALVE = "VALVE"
const SAVING = "SAVING"
const ENDME = "ENDME"

var hand_controller: PlayerHand
var player: PlayerTest
var player_interact: PlayerInteract
var other_hand: PlayerHand

@export var moving_breaks_free: bool
@export var turning_breaks_free: bool
@export var crouching_breaks_free: bool

@export var anim_idle: String
@export var anim_prompt: String

func _ready() -> void:
	await owner.ready
	hand_controller = get_parent().get_parent() as PlayerHand
	assert(hand_controller != null, "HandState must be childed to PlayerHand node - " + name)
	player = hand_controller.player as PlayerTest
	player_interact = hand_controller.player_interact as PlayerInteract
	other_hand = player_interact.get_other_hand(hand_controller.hand_type)

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass
