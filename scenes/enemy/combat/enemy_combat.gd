class_name EnemyCombat
extends Node

var player: PlayerTest

var is_in_combat_mode: bool = true

@export var combat_ui: Control

@export var combat_hands: Array[CombatHand]

@export var stance: Stance
var enemy_stance: Stance

func _ready() -> void:
	#enter_combat_mode()
	stance.hands = combat_hands

func enter_combat_mode() -> void:
	is_in_combat_mode = true
	combat_ui.visible = true
	for hand in combat_hands:
		hand.become_active()
		hand.enemy_stance = enemy_stance

func exit_combat_mode() -> void:
	is_in_combat_mode = false
	combat_ui.visible = false
	for hand in combat_hands:
		hand.become_in_active()
		hand.enemy_stance = enemy_stance
