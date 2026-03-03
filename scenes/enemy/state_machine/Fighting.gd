extends NodeState

@export var combat: EnemyCombat

var player : PlayerTest

@export var Body : CharacterBody3D # for shmoovment


func on_process(delta : float):
	## here comabt comence but not final 
	## goes to the specific node of fighting style (pattern) and executes that code
	Body.look_at(player.global_position, Vector3.UP)
	Body.rotation.x = 0
	Body.rotation.z = 0
	pass
var noded

func enter():
	player = owner.player
	##combat.enemy_stance = player.combat.stance
	combat.enter_combat_mode()
	Animator.play("AttackN")

func exit():
	combat.enemy_stance = null
	combat.exit_combat_mode()
	pass


func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.owner is PlayerTest:
		SM.transition_to("Chase")
		pass
	
