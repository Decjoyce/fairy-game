extends NodeState

@export var combat: EnemyCombat

var player : PlayerTest

func on_process(delta : float):
	## here comabt comence but not final 
	## goes to the specific node of fighting style (pattern) and executes that code
	
	pass
var noded

func enter():
	noded = get_tree().get_first_node_in_group("Player")
	if get_tree().get_first_node_in_group("Player"):
		player = get_tree().get_first_node_in_group("Player")
	combat.enter_combat_mode()
	combat.enemy_stance = player.combat.stance

func exit():
	combat.enemy_stance = null
	pass
