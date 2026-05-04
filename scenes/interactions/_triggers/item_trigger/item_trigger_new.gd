extends Area3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var do_once: bool
@export var exempt_keyword: String = "PERM"
@export var delete_obj_after_use: bool

var activated: bool

func _on_item_entered(area: Area3D) -> void:
	if do_once and activated: return
	if area.get_parent() is Grabbable_Item:
		if keyword_checker(area.get_parent()):
			activate()


func _on_item_exited(area: Area3D) -> void:
	if do_once and activated: return
	if area.get_parent() is Grabbable_Item:
		if keyword_checker(area.get_parent()):
			deactivate()

func activate() -> void:
	if do_once and activated: return
	on_change.emit(1.0)
	on_activated.emit(1.0)
	activated = true

func deactivate() -> void:
	if do_once and activated: return
	on_change.emit(0)
	on_deactivated.emit(0)
	activated = false

func keyword_checker(_item: Grabbable_Item) -> bool:
	var split_keywords_items := _item.keywords.split(";", false)
	
	var checker: int = 0
	for kw in split_keywords_items:
		if kw == exempt_keyword: checker+=1
	return checker >= 1
