class_name PlayerCombat
extends Node

var is_in_combat_mode: bool = true

@onready var combat_ui: Control = $Combat_UI

@export var combat_hands: Array[CombatHand]

@onready var stance: Stance = $Stance
var enemy_stance: Stance

@export var stats: Stats 

func _ready() -> void:
	enter_combat_mode()
	stance.stats = stats
	stance.hands = combat_hands

func enter_combat_mode() -> void:
	is_in_combat_mode = true
	combat_ui.visible = true
	combat_hands[0].become_active()
	combat_hands[1].become_active()

func exit_combat_mode() -> void:
	is_in_combat_mode = false
	combat_ui.visible = false
	combat_hands[0].become_in_active()
	combat_hands[1].become_in_active()
