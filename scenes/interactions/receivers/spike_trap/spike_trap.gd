extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var col: CollisionShape3D = $Spikes/StaticBody3D/CollisionShape3D

var people_inside: Array[Node3D]

func activate(sig: float) -> void:
	anim.play("spike_up")
	col.set_deferred("disabled", true)
	for peep in people_inside:
		pass
		peep.stats.take_damage(100)

func deactivate(sig: float) -> void:
	if anim.current_animation == "spike_down": return
	anim.play("spike_down")
	col.set_deferred("disabled", false)
	for peep in people_inside:
		peep.stats.take_damage(100)

func _on_area_3d_area_entered(area: Area3D) -> void:
	#if area is EnemyHitbox and !people_inside.has(area):
	#	people_inside.append(area)
	#	activate(1)
	if area.get_parent() is PlayerTest and people_inside.has(area.get_parent()):
		people_inside.append(area.get_parent())
		activate(1)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if people_inside.has(area):
		people_inside.erase(area)
