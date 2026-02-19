extends Node

@export var item: Grabbable_Item
@export var pick_random_item: bool
@export var random_item_list: Array[Grabbable_Item]
@export var holder: Node
@export var spawn_point: Node3D

func spawn_item(sig: float) -> void:
	var spawned_item: Grabbable_Item = null
	if pick_random_item:
		spawned_item = random_item_list.pick_random().duplicate()
	else:
		spawned_item = item.duplicate()
	
	holder.add_child(spawned_item)
	spawned_item.global_position = spawn_point.global_position
	spawned_item.global_rotation = spawned_item.global_rotation
