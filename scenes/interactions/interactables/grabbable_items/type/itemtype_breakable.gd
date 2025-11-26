class_name ItemType_Breakable
extends ItemType

@export var use_random_item: bool
@export var random_item_chance: float = 0.5
@export var random_items: Array[PackedScene]
@export var specific_item_to_drop: PackedScene

var ran_num: RandomNumberGenerator = RandomNumberGenerator.new()

func get_item_to_spawn() -> PackedScene:
	if !random_items: return specific_item_to_drop
	if randf_range(0, 1) <= random_item_chance: return random_items.pick_random()
	else: return null
