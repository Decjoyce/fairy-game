class_name Player_CombatHand
extends CombatHand

@export var stringed_hand: String
var current_angle: float


# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Defend Stuff ↓


func begin_defending() -> void:
	super()

func defending() -> void:
	var joystick_motion:= Input.get_vector(stringed_hand + "_joystick_left", stringed_hand + "_joystick_right", stringed_hand + "_joystick_down", stringed_hand + "_joystick_up")
	if joystick_motion:
		move_into_slot(get_stance_angle(joystick_motion))

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
