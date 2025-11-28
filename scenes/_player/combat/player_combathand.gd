class_name Player_CombatHand
extends CombatHand

@export var stringed_hand: String
var current_angle: float

@export var combat: PlayerCombat

@export var other_hand: Player_CombatHand

@export var incoming_attack_uis: Array[TextureRect] 

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Defend Stuff ↓

func get_into_anim() -> void:
	match current_slot:
		0: anim_player.play("r_idle_m")
		1: anim_player.play("r_idle_b")
		2: anim_player.play("r_idle_b")
		3: anim_player.play("l_idle_b")
		4: anim_player.play("l_idle_m")
		5: anim_player.play("l_idle_t")
		6: anim_player.play("l_idle_t")
		7: anim_player.play("r_idle_t")

func move_into_slot(slot_to_occupy: int) -> void:
	if my_stance.occupy_slot(index, slot_to_occupy):
		get_into_anim()
		current_slot = slot_to_occupy

func begin_defending() -> void:
	super()

func defending() -> void:
	if other_hand.current_combat_state != CombatHandStates.ATTACKING and Input.is_action_just_pressed("action_" + stringed_hand):
		begin_attacking()
		return
	
	var joystick_motion:= Input.get_vector(stringed_hand + "_joystick_left", stringed_hand + "_joystick_right", stringed_hand + "_joystick_down", stringed_hand + "_joystick_up")
	if joystick_motion:
		move_into_slot(get_stance_angle(joystick_motion))
		for g: TextureRect in incoming_attack_uis:
			if g == combat.incoming_attack_uis[current_slot]: g.modulate = "eb98b1ac"
			else: g.modulate = "7c0001e0"
	

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

@export var current_charge: float

func begin_attacking() -> void:
	super()
	hand_attack.player_start_attacking()
	current_charge = 0

func attacking(delta: float) -> void:
	if hand_attack.current_attack_state == hand_attack.AttackStates.TELEGRAPHING: 
		if Input.is_action_pressed("action_" + stringed_hand):
			current_charge = clampf(current_charge + delta, 0, 2)
		elif Input.is_action_just_released("action_" + stringed_hand):
			hand_attack.end_telegraph()

func end_attacking() -> void:
	pass

func attack_enemy(dmg: float) -> void:
	if combat.enemy_stance == null:
		print("hmm")
		return
	var enemy_slot := combat.enemy_stance.check_slot_to_attack(current_slot)
	if enemy_slot == null: # Can Damage
		damage_enemy(enemy_slot, dmg)
	elif enemy_slot.current_combat_state == CombatHandStates.DEFENDING:
		been_blocked(enemy_slot, dmg)
	else:
		damage_enemy(enemy_slot, dmg)

func damage_enemy(enemy_hand: CombatHand, dmg: float) -> void:
	print("dddamged")
	if current_charge >= 5: combat.enemy_stance.stats.take_damage(dmg * 2)
	else: combat.enemy_stance.stats.take_damage(dmg)
	on_damage_enemy.emit(current_slot)

# ↑ Attack Stuff ↑
# --------------------------------------------------------------------------------------------------
