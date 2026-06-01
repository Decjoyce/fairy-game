extends Area3D

signal scored(_points: int)

@export var specific_item: Grabbable_Item

func _on_item_entered(body: Node3D) -> void:
	if body is Grabbable_Item:
		if specific_item and body == specific_item:
			netted()


func _on_item_exited(body: Node3D) -> void:
	if body is Grabbable_Item:
		if specific_item and body == specific_item:
			deactivate()

func netted() -> void:
	var num_points: int
	var _con_throw_pos: Vector2 = Vector2(specific_item.last_throw_pos.x, specific_item.last_throw_pos.z)
	var dist_from_net: float = _con_throw_pos.distance_squared_to(Vector2(global_position.x, global_position.z))
	if dist_from_net >= 1: 
		num_points = 1
	elif dist_from_net > 3:
		num_points = 2
	else:
		num_points = 3
	scored.emit(num_points)

func deactivate() -> void:
	pass
