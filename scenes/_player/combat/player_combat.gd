class_name PlayerCombat
extends Node

var is_in_combat_mode: bool = true

@onready var player: PlayerTest = owner

@onready var combat_ui: Control = $Combat_UI

@export var combat_hands: Array[CombatHand]

@onready var stance: Stance = $Stance
var enemy_stance: Stance

@export var stats: Stats 

@export var incoming_attack_uis: Array[TextureRect] 

func _ready() -> void:
	#enter_combat_mode()
	stance.stats = stats
	stance.hands = combat_hands
	disable_all_inc_ui()
	for i in get_tree().get_nodes_in_group("EnemyCombatHand"):
		if i is Enemy_CombatHand:
			i.about_to_attack.connect(set_enemy_telegraph_ui_active)

func enter_combat_mode() -> void:
	is_in_combat_mode = true
	combat_ui.visible = true
	player.in_combat = true
	player.interaction.visible = false
	player.interaction.make_hands_inactive()
	combat_hands[0].become_active()
	combat_hands[1].become_active()

func exit_combat_mode() -> void:
	is_in_combat_mode = false
	combat_ui.visible = false
	player.in_combat = false
	player.interaction.visible = true
	combat_hands[0].become_in_active()
	combat_hands[1].become_in_active()

var slot_attack_coming_from: int

@onready var grap_timer: Timer = $Combat_UI/IncomingAttacks/Timer

func set_enemy_telegraph_ui_active(slot: int) -> void:
	incoming_attack_uis[slot_attack_coming_from].visible = false
	slot_attack_coming_from = slot
	incoming_attack_uis[slot_attack_coming_from].visible = true
	grap_timer.start()

func disable_all_inc_ui() -> void:
	for i in incoming_attack_uis:
		i.visible = false

func _on_timer_timeout() -> void:
	disable_all_inc_ui()


func _on_enemy_checker_on_body_entered(obj: Object) -> void:
	if obj is EnemyHitbox:
		enemy_stance = obj.combat.stance


func _on_enemy_checker_on_body_exit(obj: Object) -> void:
	if obj is EnemyHitbox and enemy_stance == obj.combat.stance:
		enemy_stance = null
