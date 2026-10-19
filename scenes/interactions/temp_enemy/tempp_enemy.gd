class_name Tempp_Enemy
extends Node3D

@export var stats: Stats

func take_damage(amount: float) -> void:
	var am_dead := stats.take_damage(amount)
	if am_dead: die()

func die()-> void:
	Debug.play_death_enemy(global_position)
