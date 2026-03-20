extends NodeState

@export var combat: EnemyCombat

var player : PlayerTest

@export var Body : CharacterBody3D # for shmoovment

@onready var timer: Timer = $Timer 

@export var tele_delay: float = 0.5
@export var recover_delay: float = 0.5

var is_attacking = false

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
	print("i entered attacky")
	is_attacking = false
	##combat.enemy_stance = player.combat.stance
	#combat.enter_combat_mode()
	charge_attack()
	

func exit():
	timer.stop()
	pass

func charge_attack() -> void:
	Animator.play("telegraph")
	print("i am chargy")
	timer.wait_time = tele_delay
	timer.start()

func attack() -> void:
	Animator.play("attack")
	print("i attack u")
	player.stats.take_damage(25.0)
	timer.wait_time = recover_delay
	timer.start()

func timeout() -> void:
	print("timerdoneyo")
	is_attacking = !is_attacking
	if is_attacking:
		attack()
	else:
		charge_attack()

func _on_area_3d_area_exited(area: Area3D) -> void:
		if area.owner != null:
			if area.owner is PlayerTest:
				SM.transition_to("Chase")
			else:
				pass
