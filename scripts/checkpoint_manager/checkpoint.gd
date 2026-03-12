@icon("res://assets/_editor_icons/icon_checkpoint_b.svg")
class_name Checkpoint
extends Node

signal on_reached_checkpoint(sig:float)
signal on_loaded_checkpoint(sig:float)

@export var spawn_pos: Node3D

var level_manager: LevelManager
var index: int
var disabled: bool

func reached_this_checkpoint(sig:float = -1) -> void:
	disabled = true
	print("oko")
	GM.reached_checkpoint(index)
