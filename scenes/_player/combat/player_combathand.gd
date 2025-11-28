class_name Player_CombatHand
extends CombatHand

@export var stringed_hand: String
var current_angle: float

@export var combat: PlayerCombat

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Defend Stuff ↓

func move_into_slot(slot_to_occupy: int) -> void:
	my_stance.occupy_slot(index, slot_to_occupy)
	current_slot = slot_to_occupy

func begin_defending() -> void:
	super()

func defending() -> void:
	var joystick_motion:= Input.get_vector(stringed_hand + "_joystick_left", stringed_hand + "_joystick_right", stringed_hand + "_joystick_down", stringed_hand + "_joystick_up")
	if joystick_motion:
		move_into_slot(get_stance_angle(joystick_motion))
	if combat.slot_attack_coming_from == current_slot:
		combat.incoming_attack_uis[current_slot].modulate = "eb98b1ac"
	else: combat.incoming_attack_uis[current_slot].modulate = "7c0001e0"

func end_defending() -> void:
	pass

func get_stance_angle(dir: Vector2) -> int:
	current_angle = rad_to_deg(atan2(dir.y, -dir.x))
	var _slot := int(floorf((current_angle + 22.5)/45) + 4)
	if _slot >= 8:
		_slot = 0
	return _slot

# ↑ Defend Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Attack Stuff ↓

func begin_attacking() -> void:
	super()

func attacking() -> void:
	pass

func end_attacking() -> void:
	pass

# ↑ Attack Stuff ↑
# --------------------------------------------------------------------------------------------------
