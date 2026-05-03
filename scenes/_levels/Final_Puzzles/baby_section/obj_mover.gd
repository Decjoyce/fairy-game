extends Node

@export var new_pos: Vector3
@export var thing_to_move: Node3D
@export var pos_to_move_to: Node3D

func move_the_thing(sig: float) -> void:
	thing_to_move.global_position = new_pos

func move_the_thing_bs(area: Object) -> void:
	thing_to_move.global_position = pos_to_move_to.global_position
