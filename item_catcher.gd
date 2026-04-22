extends Area3D

@export var return_point: Node3D

func _on_body_entered(body: Node3D) -> void:
	print("hello")
	if body is Grabbable_Item:
		body.global_position = return_point.global_position
		body.global_rotation = return_point.global_rotation
		print("DEDED")
