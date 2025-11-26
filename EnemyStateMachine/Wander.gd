extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope
# Animator for what to play
# SM for state change

func on_process(delta : float):
	if Input.is_key_pressed(KEY_9): 
		SM.transition_to("IdleState")
	
	
	pass
func enter():
	Animator.play("RESET")
	pass

func exit():
	Animator.stop()
	pass
