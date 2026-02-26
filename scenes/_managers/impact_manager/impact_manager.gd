class_name ImpactManager
extends Node3D

enum ImpactTypes {GROUND, BLOOD}

@export var holders: Array[Node3D]
var holder_indexes: Array[int] = [3]

func play_impact_at(location: Vector3, impact_type: int, impact_size: float):
	var holder := holders[impact_type]
	holder_indexes[impact_type] = wrapi(holder_indexes[impact_type]+1, 0, holder.get_child_count())
	var the_impact := holder.get_child(holder_indexes[impact_type])
	the_impact.global_position = location
	the_impact.visible = true
	var particles : GPUParticles3D = the_impact.get_node("Particles") as GPUParticles3D
	particles.emitting = true
	particles.lifetime = impact_size
