extends NodeState

@export var combat: EnemyCombat

var player : PlayerTest

func on_process(delta : float):
	## here comabt comence but not final 
	## goes to the specific node of fighting style (pattern) and executes that code
	
	pass
var noded

func enter():
	player = owner.player
	combat.enemy_stance = player.combat.stance
	combat.enter_combat_mode()
	Animator.play("Idle")

func exit():
	combat.enemy_stance = null
	combat.exit_combat_mode()
	pass


func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Chase")
