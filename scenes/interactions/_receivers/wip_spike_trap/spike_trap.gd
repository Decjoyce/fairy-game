class_name SpikeTrap
extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var col: CollisionShape3D = $Spikes/StaticBody3D/CollisionShape3D

@export var trigger_when_in: bool = true
@export var only_trig_once: bool

var people_inside: Array[Entity]
var itms_inside: Array[Grabbable_Item]
var weighted_things_inside: int

var activated: bool
var has_been_triggered: bool

@export var do_not_save: bool

func activate(sig: float = -1) -> void:
	if has_been_triggered and only_trig_once: return
	if activated: return
	#print("activated")
	activated = true
	anim.play("spike_up")
	col.set_deferred("disabled", false)
	has_been_triggered = true
	dmg_things_inide()

func deactivate(sig: float = -1) -> void:
	if !activated: return
	#print("deactivated")
	
	activated = false
	if anim.current_animation == "spike_down": return
	anim.play("spike_down")
	col.set_deferred("disabled", true)
	dmg_things_inide()

func dmg_things_inide() -> void:
	for peep in people_inside:
		peep.stats.take_damage(100, 2)
	for itm in itms_inside:
		if itm.can_break:
			if itm.item_weight == Grabbable_Item.item_weight_types.HEAVY: weighted_things_inside -= 1
			itm.break_item()
			itms_inside.erase(itm)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent() is Entity and !people_inside.has(area.get_parent()):
		people_inside.append(area.get_parent())
		weighted_things_inside += 1
		print("ho")
		if trigger_when_in: activate(-1)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() is not Entity: return
	if !people_inside.has(area.get_parent()): return
	people_inside.erase(area.get_parent())
	print(people_inside)
	weighted_things_inside -= 1
	if weighted_things_inside <= 0:
		if trigger_when_in: deactivate(-1)


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("jig")
	if body is Grabbable_Item:
		print("ji")
		if itms_inside.has(body): return
		print(itms_inside.has(body))
		print("kokokokokoko")
		itms_inside.append(body as Grabbable_Item)
		print(itms_inside)
		if body.item_weight == Grabbable_Item.item_weight_types.HEAVY:
			weighted_things_inside += 1
			if trigger_when_in: activate(-1) 


func _on_area_3d_body_exited(body: Node3D) -> void:
	if !itms_inside.has(body): return
	print("bodyleft")
	var itm: Grabbable_Item = body as Grabbable_Item
	if body.item_weight == Grabbable_Item.item_weight_types.HEAVY:
			weighted_things_inside -= 1
	itms_inside.erase(body)
	if weighted_things_inside <= 0:
		if trigger_when_in: deactivate(-1)
