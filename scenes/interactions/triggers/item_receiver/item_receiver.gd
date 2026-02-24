class_name ItemReceiver
extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)

enum ItemReceiverStyle {BY_TYPE, BY_KEYWORD, SPECIFIC_ITEMS, EITHER, ANY_ITEM}
@export var receiver_type: ItemReceiverStyle

@export var infinite_use: bool

@export_category("If BY_TYPE or EITHER")
@export var type_of_item: ItemType.ItemTypes = ItemType.ItemTypes.KEY
@export var num_needed_by_type: int
var num_have_by_type: int

@export_category("If BY_KEYWORD or EITHER")
@export var keywords_needed: String ## Separate keywords with ; . Do not include spaces
@export var num_needed_by_keyword: int
var num_have_by_keyword: int

@export_category("If SPECIFIC_ITEMS or EITHER")
@export var specific_items_to_recieve: Array[Grabbable_Item] ## The Item Receiver must receive these items before being enabled
var needed_items_left: Array[Grabbable_Item]

@export_category("If ANY")
@export var num_needed_for_any: int 
var num_have_for_any: int 

@export_category("Destroy?")
@export var destroy_items_on_receive: bool

@export_category("Aesthetics")
@export var hand_prompt: String = "hand_prompt_default"
@export var prompt_text: String = ""

@export_category("Items")
@export var func_to_call: String
@export var args: Array

var is_activated: bool
@onready var col: CollisionShape3D = %_col

var disabled: bool

func _ready() -> void:
	needed_items_left.assign(specific_items_to_recieve)

func check_if_need_item(_item: Grabbable_Item) -> bool:
	if receiver_type == ItemReceiverStyle.ANY_ITEM: return true
	elif receiver_type == ItemReceiverStyle.SPECIFIC_ITEMS and specific_items_to_recieve.has(_item):
		return true
	elif receiver_type == ItemReceiverStyle.BY_TYPE and _item.item_type.item_type == type_of_item:
		return true
	elif receiver_type == ItemReceiverStyle.BY_KEYWORD and keyword_checker(_item):
		return true
	elif receiver_type == ItemReceiverStyle.EITHER and (specific_items_to_recieve.has(_item) or _item.item_type.item_type == type_of_item): return true
	else: return false

func receive_item(_item: Grabbable_Item) -> bool:
	match receiver_type:
		0: # by type
			return check_item_by_type(_item)
		1: # by type
			return check_item_by_keyword(_item)
		2: # by specific
			return check_item_is_specific(_item)
		3: # either
			return check_item_is_either(_item)
		4: # any item
			return check_if_any(_item)
		_:
			print("bro u messed up")
			return false

func all_items_received() -> void:
	if is_activated or infinite_use: return
	on_activated.emit(1.0)
	is_activated = true
	col.set_deferred("disabled", true)

# ↑ Receiving Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checking Stuff ↓

func check_item_by_type(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if _item.item_type.item_type != type_of_item: return false
	if func_to_call != "":
		if args: _item.call(func_to_call, args)
		else: _item.call(func_to_call)
	
	check_if_item_should_be_destroyed(_item)
	
	num_have_by_type += 1
	
	on_change.emit(float(num_have_by_type) / float(num_needed_by_type))
	
	if num_have_by_type >= num_needed_by_type:
		all_items_received()
	
	return true

func check_item_by_keyword(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if _item.keywords == "": return false
	
	keyword_checker(_item)
	
	if func_to_call != "":
		if args: _item.call(func_to_call, args)
		else: _item.call(func_to_call)
	
	check_if_item_should_be_destroyed(_item)
	
	num_have_by_keyword += 1
	
	on_change.emit(float(num_have_by_keyword) / float(num_needed_by_keyword))
	
	if num_have_by_keyword >= num_needed_by_keyword:
		all_items_received()
	
	return true

func keyword_checker(_item: Grabbable_Item) -> bool:
	var split_keywords_needed := keywords_needed.split(";", false)
	var split_keywords_items := _item.keywords.split(";", false)
	
	var checker: int = 0
	for kw in split_keywords_items:
		if split_keywords_needed.has(kw): checker+=1
	return checker == 1

func check_item_is_specific(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if !needed_items_left.has(_item): return false
	needed_items_left.erase(_item)
	
	check_if_item_should_be_destroyed(_item)
	
	
	if needed_items_left.size() <= 0:
		on_change.emit(1)
		all_items_received()
	else: on_change.emit(float(specific_items_to_recieve.size() - needed_items_left.size()) / specific_items_to_recieve.size())
	
	return true

func check_item_is_either(_item: Grabbable_Item) -> bool:
	var needed_for_either: bool
	if check_item_is_specific(_item, false): needed_for_either = true
	if check_item_by_type(_item, false): needed_for_either = true
	if check_item_by_keyword(_item, false): needed_for_either = true
	check_if_item_should_be_destroyed(_item)
	return needed_for_either

func check_if_any(_item: Grabbable_Item) -> bool:
	num_have_for_any += 1
	check_if_item_should_be_destroyed(_item)
	on_change.emit(float(num_have_for_any) / float(num_needed_for_any))
	
	if num_have_for_any >= num_needed_for_any:
		all_items_received()
	
	return true

func check_if_item_should_be_destroyed(_item: Grabbable_Item):
	if destroy_items_on_receive: _item.queue_free()
	else: _item.global_position = Vector3.ONE * -100
