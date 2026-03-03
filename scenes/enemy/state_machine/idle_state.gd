extends NodeState

@export var Body : CharacterBody3D # for shmoovment
@export var Sprite : Sprite3DBillBoard #For animation control i hope

func on_process(delta : float):
	if Input.is_key_pressed(KEY_0): 
		SM.transition_to("wander")
	
	
	pass

func enter():
	print_debug("idleState")
	Animator.play("Idle2")
	await get_tree().create_timer(2).timeout
	RandomIdle()
	pass

func exit():
	Animator.stop()
	pass

func RandomIdle():
	var random_float = randf()
	if random_float < 0.5:
		SM.transition_to("wander")
	elif random_float < 0.6:
		await get_tree().create_timer(2).timeout
		RandomIdle()
	
	pass
