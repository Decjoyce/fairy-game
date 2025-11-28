class_name Enemy_CombatHand
extends CombatHand

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Defend Stuff ↓

@export var defense_timer: Timer

func begin_defending() -> void:
	super()
	defense_timer.wait_time = randf_range(1, 5)
	defense_timer.start()

func defending() -> void:
	#move_into_slot(enemy_stance.get_slot_hand_is_in(index))
	pass

func end_defending() -> void:
	pass

# ↑ Defend Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Attack Stuff ↓

@export_category("ATTACK STUFF")
@export var attack_sequences: Array[AttackSequence]
var current_attack_sequence: AttackSequence

func begin_attacking() -> void:
	super()
	current_attack_sequence = attack_sequences.pick_random()
	hand_attack.start_attacking(current_attack_sequence)

func attacking(delta: float) -> void:
	pass

func end_attacking() -> void:
	pass

# ↑ Attack Stuff ↑
# --------------------------------------------------------------------------------------------------
