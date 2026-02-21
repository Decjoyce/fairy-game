extends Node3D

@export var drawbridge_lever: Lever
@export var max_rotation: float = 180.0
@export var rotation_speed: float = 2.0   # Higher = faster movement

var target_rotation: float = 0.0


func _ready():
	if drawbridge_lever != null:
		drawbridge_lever.on_change.connect(_on_lever_changed)


func _process(delta):
  
	rotation_degrees.y = lerp(
		rotation_degrees.y,
		target_rotation,
		rotation_speed * delta
	)


func _on_lever_changed(value: float) -> void:
	value = clamp(value, 0.0, 1.0)
	target_rotation = value * max_rotation
