class_name CombatHand_Attack
extends Node

var my_hand: CombatHand

var is_attacking: bool
signal on_started_attacking
signal on_stopped_attacking

enum AttackStates {NOT_ATTACKING, TELEGRAPHING, ATTACKING, RECOVERING}
var current_attack_state: AttackStates

var attack_sequence: AttackSequence
var current_attack_data: AttackData
var next_attack_index: int

var anim_player: AnimationPlayer

@export var not_player: bool = true
@export var player_current_attack: AttackSequence

@onready var audio_attack: AudioStreamPlayer3D = $AttackSFX

func _ready() -> void:
	var par = get_parent()
	if par is not CombatHand:
		printerr("combathand_attack must be a child of CombatHand")
		return
	my_hand = get_parent() as CombatHand

func start_attacking(new_attack_sequence: AttackSequence) -> void:
	is_attacking = true
	on_started_attacking.emit()
	attack_sequence = new_attack_sequence
	print("stated_attack")
	next_attack()

func stop_attacking() -> void:
	print("stopped_attack")
	is_attacking = false
	current_attack_state = AttackStates.NOT_ATTACKING
	
	attack_sequence = null
	current_attack_data = null
	next_attack_index = 0
	
	timer_telegraph.stop()
	timer_attack.stop()
	timer_recover.stop()
	
	my_hand.begin_defending()
	
	on_stopped_attacking.emit()

func player_start_attacking() -> void:
	if not_player: return
	print("stated_attack")
	is_attacking = true
	on_started_attacking.emit()
	current_attack_data = player_current_attack.attack_order[my_hand.current_slot]
	player_begin_telegraph()

func player_stop_attacking() -> void:
	print("stopped_attack")
	is_attacking = false
	current_attack_state = AttackStates.NOT_ATTACKING
	timer_attack.stop()
	timer_recover.stop()
	
	my_hand.begin_defending()
	
	on_stopped_attacking.emit()

func next_attack() -> bool:
	if next_attack_index >= attack_sequence.attack_order.size(): 
		print("couldnt_get_next_attack")
		stop_attacking()
		return false
	
	print("got_next_attack")
	current_attack_data = attack_sequence.attack_order[next_attack_index]
	next_attack_index += 1
	begin_telegraph()
	return true

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Telegraph Stuff ↓

##-- TO DO: Make this more flexible to allow for player input instead of timer --##

signal on_begin_telegraph
signal on_end_telegraph
@onready var timer_telegraph: Timer = $Timer_Telegraph # length of attack

func player_begin_telegraph() -> void:
	print("began_telegraph")
	
	current_attack_state = AttackStates.TELEGRAPHING
	
	on_begin_telegraph.emit()
	
	my_hand.anim_player.play(current_attack_data.telegraph_anim)
	
#	audio_attack.stream = current_attack_data.telegraph_audio
	audio_attack.play()
	
	my_hand.about_to_attack.emit(my_hand.current_slot)

func begin_telegraph() -> void:
	print("began_telegraph")
	
	current_attack_state = AttackStates.TELEGRAPHING
	
	on_begin_telegraph.emit()
	
	my_hand.anim_player.play(current_attack_data.telegraph_anim)
	
	audio_attack.stream = current_attack_data.telegraph_audio
	
	if not_player:
		my_hand.current_slot = current_attack_data.slot
	
	my_hand.about_to_attack.emit(my_hand.current_slot)
	audio_attack.play()
	
	timer_telegraph.wait_time = current_attack_data.telegraph_length
	timer_telegraph.start()

func end_telegraph() -> void:
	print("ended_telegraph")
	on_end_telegraph.emit()
	begin_attack()

# ↑ Telegraph Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Attacking Stuff ↓

signal on_begin_attack
signal on_end_attack
@onready var timer_attack: Timer = $Timer_Attack # length of attack

func begin_attack() -> void:
	print("began_attack")
	current_attack_state = AttackStates.ATTACKING
	
	on_begin_attack.emit()
	
	my_hand.anim_player.play(current_attack_data.attack_anim)
	
	#audio_attack.stream = current_attack_data.attack_audio
	audio_attack.play()
	
	timer_attack.wait_time = current_attack_data.attack_length
	timer_attack.start()
	
	my_hand.attack_enemy(current_attack_data.dmg)


func end_attack() -> void:
	print("ended_attack")
	on_end_attack.emit()
	begin_recover()

# ↑ Attacking Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Recovering Stuff ↓

signal on_begin_recover
signal on_end_recover
@onready var timer_recover: Timer = $Timer_Recover # lenght of recovery

func begin_recover() -> void:
	print("begin_recover")
	current_attack_state = AttackStates.RECOVERING
	on_begin_recover.emit()
	my_hand.anim_player.play(current_attack_data.recover_anim, -1,  1 + current_attack_data.recover_length)
	timer_recover.wait_time = current_attack_data.recover_length
	
	#audio_attack.stream = current_attack_data.recover_audio
	audio_attack.play()
	
	timer_recover.start()

func end_recover() -> void:
	print("ended_recover")
	on_end_recover.emit()
	if not_player:
		next_attack()
	else:
		stop_attacking()
