extends Area3D

signal on_activate(sig: float)
signal on_deactivate(sig: float)

var items_in_zone: Array[Grabbable_Item]
@onready var eyes: Node3D = %Eyes
@export var exempt_keyword: String = "PERM" ## Items with this keyword will not trigger the observer

func enter_lockdown() -> void:
	eyes.visible = true
	on_activate.emit(1.0)

func exit_lockdown() -> void:
	eyes.visible = false
	on_activate.emit(0)

func check_if_should_lockdown() -> bool:
	return items_in_zone.size() > 0

func on_item_area_entered(area: Area3D) -> void:
	if area.get_parent() is not Grabbable_Item: return
	if items_in_zone.has(area.get_parent()): return
	if keyword_checker(area.get_parent()): return
	items_in_zone.append(area.get_parent())
	if check_if_should_lockdown():
		enter_lockdown()

func on_item_area_exited(area: Area3D) -> void:
	if area.get_parent() is not Grabbable_Item: return
	if !items_in_zone.has(area.get_parent()): return
	items_in_zone.erase(area.get_parent())
	if !check_if_should_lockdown():
		exit_lockdown()

func keyword_checker(_item: Grabbable_Item) -> bool:
	var split_keywords_items := _item.keywords.split(";", false)
	
	var checker: int = 0
	for kw in split_keywords_items:
		if kw == exempt_keyword: checker+=1
	return checker >= 1
