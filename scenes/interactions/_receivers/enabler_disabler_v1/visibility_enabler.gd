extends Node

@export var linked_node: Node3D

func enable_obj(sig: float) -> void:
	linked_node.visible = true
	print("Ensbale")

func disable_obj(sig: float) -> void:
	linked_node.visible = false
	print("Disbale")

func toggle_visibilty(sig: float) -> void:
	linked_node.visible = !linked_node.visible
	print(linked_node.visible)

func disable_obj_using_area(obj: Object) -> void:
	linked_node.queue_free()
