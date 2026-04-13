extends Area3D

signal on_activate(sig: float)
signal on_deactivate(sig: float)

var items_in_zone: Array[Grabbable_Item]
@onready var head: Node3D = $Pivot/cairn_saving_head
@onready var eyes: Node3D = %Eyes
@onready var itm_shower_holder: Node3D = $Item_Showers
@onready var facing_helper: Node3D = $Pivot/facing_helper

@export var exempt_keyword: String = "PERM" ## Items with this keyword will not trigger the observer

@export var itm_showers: Array[Node3D]

var activated: bool

var eye_tween: Tween

func _physics_process(delta: float) -> void:
	if activated:
		facing_helper.look_at(items_in_zone.back().global_position, Vector3.UP, true)
		head.rotation = lerp(head.rotation, facing_helper.rotation, 0.7 * delta)
	else:
		head.rotation = lerp(head.rotation, Vector3.ZERO, 0.0001 * delta)

func enter_lockdown() -> void:
	if activated: return
	eyes.scale = Vector3.ONE * 0.9
	eyes.visible = true
	on_activate.emit(1.0)
	activated = true
	if eye_tween: eye_tween.stop()
	eye_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	eye_tween.set_parallel(true)
	eye_tween.tween_property(eyes, "scale", Vector3.ONE, 0.5)

func exit_lockdown() -> void:
	if !activated: return
	#eyes.visible = false
	on_activate.emit(0)
	head.rotation = Vector3.ZERO
	activated = false
	if eye_tween: eye_tween.stop()
	eye_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	eye_tween.set_parallel(true)
	eye_tween.tween_property(eyes, "scale", Vector3.ZERO, 3)

func check_if_should_lockdown() -> bool:
	return items_in_zone.size() > 0

func on_item_area_entered(area: Area3D) -> void:
	if area.get_parent() is not Grabbable_Item: return
	if items_in_zone.has(area.get_parent()): return
	if keyword_checker(area.get_parent()): return
	items_in_zone.append(area.get_parent())
	hover_shower()
	if check_if_should_lockdown():
		enter_lockdown()

func on_item_area_exited(area: Area3D) -> void:
	if area.get_parent() is not Grabbable_Item: return
	if !items_in_zone.has(area.get_parent()): return
	items_in_zone.erase(area.get_parent())
	hover_shower()
	if !check_if_should_lockdown():
		exit_lockdown()
		print("d")

func hover_shower() -> void:
	for i in itm_showers.size():
		if i >= items_in_zone.size(): itm_showers[i].reparent(itm_shower_holder)
		else: itm_showers[i].reparent(items_in_zone[i])
		itm_showers[i].position = Vector3.ZERO

func keyword_checker(_item: Grabbable_Item) -> bool:
	var split_keywords_items := _item.keywords.split(";", false)
	
	var checker: int = 0
	for kw in split_keywords_items:
		if kw == exempt_keyword: checker+=1
	return checker >= 1
