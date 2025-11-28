extends CharacterBody3D

@export var player: PlayerTest

func die() -> void:
	queue_free()
