extends Node3D

@export var drawbridge_lever: Lever
@export var max_rotation: float = -90
@export var rotation_speed: float = 0.5   # Higher = faster

var target_rotation: float = 0.0


func _ready():
	if drawbridge_lever != null:
		drawbridge_lever.on_change.connect(_on_lever_changed)


func _process(delta):
  
	rotation_degrees.z = lerp(
		rotation_degrees.z,
		target_rotation,
		rotation_speed * delta
	)


func _on_lever_changed(value: float) -> void:
	value = clamp(value, 0.0, 1.0)
	target_rotation = value * max_rotation
