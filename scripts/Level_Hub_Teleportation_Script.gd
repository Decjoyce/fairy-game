extends Area3D
@export_file ("*.tscn") var test_scenes: String


func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		get_tree().change_scene_to_file(test_scenes)
		print("interacted")
