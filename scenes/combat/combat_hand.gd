class_name CombatHand
extends Node

var is_in_combat: bool

@export var index: int # the index that this hand is at

@export var current_slot: int = -1 # -1 is not occupying any slot
@export var restricted_slots: String = "00000000"
@export var my_stance: Stance
var enemy_stance: Stance

enum CombatHandStates {INACTIVE, DEFENDING, ATTACKING, STAGGERED}
var current_combat_state: CombatHandStates

@export var anim_player: AnimationPlayer

@export var block_audio_player: AudioStreamPlayer3D

func _process(delta: float) -> void:
	if !is_in_combat: return
	match current_combat_state:
		1: # DEFENDING
			defending()
		2: # ATTACKING
			attacking(delta)
		_: # STAGGERED
			return

func become_active()-> void:
	current_combat_state = CombatHandStates.DEFENDING
	begin_defending()
	is_in_combat = true

func become_in_active()-> void:
	current_combat_state = CombatHandStates.INACTIVE
	is_in_combat = false
	hand_attack.stop_attacking()

func move_into_slot(slot_to_occupy: int) -> void:
	my_stance.occupy_slot(index, slot_to_occupy)
	current_slot = slot_to_occupy

func attack_enemy(dmg: float) -> void:
	if enemy_stance == null:
		print("hmm")
		return
	var enemy_slot := enemy_stance.check_slot_to_attack(current_slot)
	if enemy_slot == null: # Can Damage
		damage_enemy(enemy_slot, dmg)
	elif enemy_slot.current_combat_state == CombatHandStates.DEFENDING:
		been_blocked(enemy_slot, dmg)
	else:
		damage_enemy(enemy_slot, dmg)

signal about_to_attack(slot: int)

func damage_enemy(enemy_hand: CombatHand, dmg: float) -> void:
	print("dddamged")
	enemy_stance.stats.take_damage(dmg)
	on_damage_enemy.emit(current_slot)

func block_enemy() -> void:
	on_block_enemy.emit(current_slot)
	block_audio_player.play()
	#my_stance.stats.take_stamina(attack_data.dmg)

func been_blocked(enemy_hand: CombatHand, dmg: float) -> void:
	print("bblocked")
	enemy_hand.block_enemy()
	on_been_blocked.emit(current_slot)

signal on_damage_enemy(slot: int)
signal on_been_blocked(slot: int)
signal on_block_enemy(slot: int)

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Defend Stuff ↓


func begin_defending() -> void:
	current_combat_state = CombatHandStates.DEFENDING

func defending() -> void:
	pass

func end_defending() -> void:
	pass

# ↑ Defend Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Attack Stuff ↓

@onready var hand_attack: CombatHand_Attack = $Attack

func begin_attacking() -> void:
	current_combat_state = CombatHandStates.ATTACKING

func attacking(delta: float) -> void:
	pass

func end_attacking() -> void:
	pass

# ↑ Attack Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Stagger Stuff ↓

@onready var timer_stagger: Timer
signal on_begin_staggered(hand_index:int, stagger_amount: float)
signal on_end_staggered(hand_index:int)

func begin_stagger(stagger_amount: int) -> void:
	if stagger_amount == 0: return
	var _stag_amount: float = 1 / stagger_amount
	timer_stagger.wait_time = _stag_amount
	on_begin_staggered.emit(index, _stag_amount)
	current_combat_state = CombatHandStates.STAGGERED
	hand_attack.stop_attacking()

func end_staggered() -> void:
	current_combat_state = CombatHandStates.DEFENDING
	on_end_staggered.emit(index)
