extends Node

@export var item: PackedScene
@export var pick_random_item: bool
@export var random_item_list: Array[PackedScene]
@export var holder: Node
@export var spawn_point: Node3D

func spawn_item(sig: float) -> void:
	var spawned_item: Grabbable_Item = null
	if pick_random_item:
		spawned_item = random_item_list.pick_random().instantiate()
	else:
		spawned_item = item.instantiate()
	
	holder.add_child(spawned_item)
	spawned_item.global_position = spawn_point.global_position
	spawned_item.global_rotation = spawned_item.global_rotation
