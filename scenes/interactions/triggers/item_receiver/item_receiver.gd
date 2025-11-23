class_name ItemReceiver
extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)

enum ItemReceiverStyle {BY_TYPE, SPECIFIC_ITEMS, EITHER, ANY_ITEM}
@export var receiver_type: ItemReceiverStyle

@export_category("If BY_TYPE or EITHER")
@export var type_of_item: ItemType.ItemTypes = ItemType.ItemTypes.KEY
@export var num_needed: int
var num_have: int

@export_category("If SPECIFIC_ITEMS or EITHER")
@export var specific_items_to_recieve: Array[Grabbable_Item]
var needed_items_left: Array[Grabbable_Item]

@export_category("Destroy?")
@export var destroy_items_on_receive: bool

@export_category("Aesthetics")
@export var hand_prompt: String = "hand_prompt_default"

var is_activated: bool
@onready var col: CollisionShape3D = $Area3D/CollisionShape3D 

func _ready() -> void:
	needed_items_left.assign(specific_items_to_recieve)

func receive_item(_item: Grabbable_Item) -> bool:
	match receiver_type:
		0: # by type
			return check_item_by_type(_item)
		1: # by specific
			return check_item_is_specific(_item)
		2: # either
			return check_item_is_either(_item)
		3: # any item
			return check_if_any(_item)
		_:
			print("bro u messed up")
			return false

func all_items_received() -> void:
	if is_activated: return
	on_activated.emit(1.0)
	is_activated = true
	col.disabled = true

# ↑ Receiving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checking Stuff ↓

func check_item_by_type(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if _item.item_type.item_type != type_of_item: return false
	check_if_item_should_be_destroyed(_item)
	
	num_have += 1
	
	on_change.emit(float(num_have) / float(num_needed))
	
	if num_have >= num_needed:
		all_items_received()
	
	return true

func check_item_is_specific(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if !needed_items_left.has(_item): return false
	needed_items_left.erase(_item)
	
	check_if_item_should_be_destroyed(_item)
	
	
	if needed_items_left.size() <= 0:
		on_change.emit(1)
		all_items_received()
	else: on_change.emit((specific_items_to_recieve.size() - needed_items_left.size()) / specific_items_to_recieve.size())
	
	return true

func check_item_is_either(_item: Grabbable_Item) -> bool:
	var needed_for_either: bool
	if check_item_is_specific(_item, false): needed_for_either = true
	if check_item_by_type(_item, false): needed_for_either = true
	check_if_item_should_be_destroyed(_item)
	return needed_for_either

func check_if_any(_item: Grabbable_Item) -> bool:
	num_have += 1
	check_if_item_should_be_destroyed(_item)
	on_change.emit(float(num_have) / float(num_needed))
	
	if num_have >= num_needed:
		all_items_received()
	
	return true

func check_if_item_should_be_destroyed(_item: Grabbable_Item):
	if destroy_items_on_receive: _item.queue_free()
	else: _item.global_position = Vector3.ONE * -100
