extends Node3D

@export var trap: SpikeTrap

func _ready() -> void:
	trap.col.set_deferred("disabled", true)
	trap.disabled = true

func boogie()-> void:
	trap.col.set_deferred("disabled", false)
	trap.disabled = false
	trap.global_position = trap.global_position.round()
	#trap.activate()
