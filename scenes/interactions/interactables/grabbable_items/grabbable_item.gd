class_name Grabbable_Item
extends Interactable

var is_grabbed: bool = false

@export var rb: RigidBody3D

@export var grabbed_offset: Vector3 = Vector3.ZERO

@export var throw_distance : float = 8.0

@export var idle_graphics: Node3D
@export var grabbed_graphics: Node3D
@export var untouched_graphics: Node3D

enum item_weight_types {WEIGHTLESS, LIGHT, MEDIUM, HEAVY}
@export var item_weight: item_weight_types

func _ready() -> void:
	interaction_type = InteractTypes.GRAB_ITEM

func begin_interact(sig: float = -1) -> void:
	if grabbed_graphics:
		if untouched_graphics: untouched_graphics.visible = false
		idle_graphics.visible = false
		grabbed_graphics.visible = true
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	#if grabbed_graphics: grabbed_graphics.visible = false
	#idle_graphics.visible = true
	
	rb.freeze = false
	rb.linear_velocity = Vector3.ZERO

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Use Stuff ↓

func begin_using_item() -> void:
	pass

func using_item() -> void:
	pass

func end_using_item() -> void:
	pass

# ↑ Use Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Item Stuff ↓

func throw(_throw_mult: float) -> void:
	rb.linear_velocity = Vector3.ZERO
	rb.freeze = false
	var throw_force := throw_distance * _throw_mult
	throw_force = sqrt(throw_force * -2 * rb.get_gravity().y)
	prints(_throw_mult, throw_distance * _throw_mult, throw_force)
	rb.apply_central_impulse(-basis.z * throw_force * rb.mass)
