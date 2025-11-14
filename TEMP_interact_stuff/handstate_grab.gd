class_name HandState_Grab
extends HandState

var is_ready: bool

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if is_ready:
		if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type):
			begin_charge()
	if Input.is_action_pressed("action_" + hand_controller.stringed_hand_type):
			charging(_delta)
	if is_charging and Input.is_action_just_released("action_" + hand_controller.stringed_hand_type):
			end_charge()
	
	grabbing()

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	grabbed_item = hand_controller.hovering_interactable
	await get_tree().create_timer(0.5)
	is_ready = true
	time_held_down = 0

func exit() -> void:
	is_ready = false

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

const GRAB_DIST = 1
var grabbed_item: Interactable

func grabbing() -> void:
	var origin = hand_controller.cam.project_ray_origin(hand_controller.get_screen_position() + hand_controller.size/2)
	var end = origin + hand_controller.cam.project_ray_normal(hand_controller.position + hand_controller.size/2) * GRAB_DIST
	grabbed_item.global_position = end
	grabbed_item.rotation = hand_controller.player.rotation

# ↑ Grabbing Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Charge Stuff ↓

var is_charging: bool 
var charge_amount: float
@export var delay_before_max_charge = 2
var time_held_down: float = 0.0

func begin_charge() -> void:
	is_charging = true
	charge_amount = 0
	time_held_down = 0
	
func charging(_delta: float) -> void:
	time_held_down += _delta
	var _charged_amount = time_held_down / delay_before_max_charge
	
	charge_amount = clampf(_charged_amount, 0.0, 1.0)
	
func end_charge() -> void:
	if charge_amount < 0.2: grabbed_item.on_end_interact()
	else: grabbed_item.throw(charge_amount)
	
	finished.emit(FREE)
	
	is_charging = false
	charge_amount = 0
	time_held_down = 0
