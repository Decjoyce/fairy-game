extends Node

@export var col: CollisionShape3D

func enable_obj(sig: float) -> void:
	col.set_deferred("disabled", false)

func disable_obj(sig: float) -> void:
	col.set_deferred("disabled", true)

func enable_obj_by_area(area: Area3D) -> void:
	col.set_deferred("disabled", false)

func disable_obj_by_area(area: Area3D) -> void:
	col.set_deferred("disabled", true)


func enable_obj_by_obj(area: Object) -> void:
	col.set_deferred("disabled", false)

func disable_obj_by_obj(area: Object) -> void:
	col.set_deferred("disabled", true)
