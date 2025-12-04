extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer

var people_inside: Array[EnemyHitbox]

func activate(sig: float) -> void:
	anim.play("spike_up")
	for peep in people_inside:
		peep.combat.stance.stats.take_damage(100)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHitbox and !people_inside.has(area):
		people_inside.append(area)
		activate(1)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if people_inside.has(area):
		people_inside.erase(area)
