class_name Grabbable_Item
extends Interactable

var is_grabbed: bool = false

@export var rb: RigidBody3D

@export var throw_distance : float = 8.0

@export var idle_graphics: Node3D
@export var grabbed_graphics: Node3D
@export var untouched_graphics: Node3D

func _ready() -> void:
	interaction_type = InteractTypes.GRAB_ITEM

func on_begin_interact() -> void:
	if grabbed_graphics:
		if untouched_graphics: untouched_graphics.visible = false
		idle_graphics.visible = false
		grabbed_graphics.visible = true
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO

func on_interacting() -> void:
	pass

func on_end_interact() -> void:
	if grabbed_graphics: grabbed_graphics.visible = false
	idle_graphics.visible = true
	
	rb.freeze = false
	rb.linear_velocity = Vector3.ZERO

func throw(_throw_mult: float) -> void:
	rb.linear_velocity = Vector3.ZERO
	rb.freeze = false
	var throw_force := throw_distance * _throw_mult
	throw_force = sqrt(throw_force * -2 * rb.get_gravity().y)
	prints(_throw_mult, throw_distance * _throw_mult, throw_force)
	rb.apply_central_impulse(-basis.z * throw_force * rb.mass)
