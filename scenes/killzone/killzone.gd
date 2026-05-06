extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		var p: PlayerTest = area.get_parent() as PlayerTest
		p.stats.take_damage(1000, 0)
