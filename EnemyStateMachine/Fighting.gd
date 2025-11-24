extends NodeState


var player : CharacterBody3D

func on_process(delta : float):
	## here comabt comence but not final 
	## goes to the specific node of fighting style (pattern) and executes that code
	
	pass

func enter():
	player = get_tree().get_nodes_in_group("Player")[0] as CharacterBody3D

func exit():
	pass
