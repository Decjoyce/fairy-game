extends Node

@export var new_pos: Vector3
@export var thing_to_move: Node3D

func move_the_thing(sig: float) -> void:
	thing_to_move.global_position = new_pos

func move_the_thing_bs(area: Object) -> void:
	thing_to_move.global_position = new_pos
