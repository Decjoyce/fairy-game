extends Node

@export var scene_to_purge: Node

func purge_scene(sig: float = -1.0) -> void:
	scene_to_purge.queue_free()
	scene_to_purge = null
	
