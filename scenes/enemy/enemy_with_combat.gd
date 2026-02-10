extends CharacterBody3D

@export var player: PlayerTest

signal hey_joy(sig: float)

func die() -> void:
	hey_joy.emit(1.0)
	Debug.death_audio_enemy.play()
	queue_free()
