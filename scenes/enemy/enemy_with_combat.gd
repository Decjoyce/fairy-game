extends CharacterBody3D

@export var player: PlayerTest

signal on_die(sig: float)

@onready var sm: NodeStateMachine = $StateMachine

func die() -> void:
	on_die.emit(1.0)
	Debug.death_audio_enemy.play()
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	print("ji")
	if body is Grabbable_Item:
		if body.prev_velocity.length() > 5:
			sm.transition_to("stunned")
