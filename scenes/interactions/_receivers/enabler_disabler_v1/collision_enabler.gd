extends Node

@export var col: CollisionShape3D

func enable_obj(sig: float) -> void:
	col.set_deferred("disabled", false)

func disable_obj(sig: float) -> void:
	col.set_deferred("disabled", true)
