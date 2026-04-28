extends Node

@export var cols: Array[CollisionShape3D]

func enable_obj(sig: float) -> void:
	for col in cols:
		col.set_deferred("disabled", false)

func disable_obj(sig: float) -> void:
	for col in cols:
		col.set_deferred("disabled", true)

func enable_obj_by_area(area: Area3D) -> void:
	for col in cols:
		col.set_deferred("disabled", false)

func disable_obj_by_area(area: Area3D) -> void:
	for col in cols:
		col.set_deferred("disabled", true)

func enable_obj_by_obj(area: Object) -> void:
	for col in cols:
		col.set_deferred("disabled", false)

func disable_obj_byobj(area: Object) -> void:
	for col in cols:
		col.set_deferred("disabled", true)
