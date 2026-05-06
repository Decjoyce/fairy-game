extends Area3D

var has_saved: bool



func _on_area_entered(area: Area3D) -> void:
	if has_saved: return
	TEMPSaveGameHandler.save_game()
	has_saved = true
