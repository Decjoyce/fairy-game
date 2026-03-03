extends NodeState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enter():
	print_debug("BONK!")
	Animator.play("Stunned")
	await get_tree().create_timer(1).timeout
	SM.transition_to("Chase")
	pass

func exit():
	Animator.stop()
	pass
