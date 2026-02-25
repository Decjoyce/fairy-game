extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope

func on_process(delta : float):
	if Input.is_key_pressed(KEY_0): 
		SM.transition_to("wander")
	
	
	pass

func enter():
	print_debug("idleState")
	Animator.play("Idle")
	pass

func exit():
	Animator.stop()
	pass
