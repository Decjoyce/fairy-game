class_name StatueSection
extends Node3D

@export var instantiate_point: Node3D
@export var baby_scene: PackedScene

func statue_finished(sig: float = -1.0) -> void:
	#return
	var babyscene : Node3D = baby_scene.instantiate() as Node3D
	instantiate_point.add_child(babyscene)
