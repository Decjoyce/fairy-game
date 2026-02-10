class_name ItemCallable
extends Resource

@export var type_required: ItemType.ItemTypes = -1
@export var func_to_call: String
@export var args: Array

func call_func_on_item(_item: Grabbable_Item) -> void:
	_item.call(func_to_call, args)
