class_name ItemType_Breakable
extends ItemType

@export var use_random_item: bool
@export var random_items: Array[PackedScene]
@export var specific_item_to_drop: PackedScene

func get_item_to_spawn() -> PackedScene:
	if !random_items: return specific_item_to_drop
	return random_items.pick_random()
