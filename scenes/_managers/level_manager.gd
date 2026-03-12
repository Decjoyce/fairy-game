class_name LevelManager
extends Node

@export var player: PlayerTest

@export var checkpoints: Array[Checkpoint]

func _ready() -> void:
	init_checkpoints()
	print(get_instance_id())

# ↑ Sequence Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checkpoint Stuff ↓

func init_checkpoints() -> void:
	for i in checkpoints.size():
		checkpoints[i].index = i
		checkpoints[i].level_manager = self
		if i < GM.cur_checkpoint:
			checkpoints[i].disabled = true

func load_checkpoint(cp: int) -> void:
	player.movement.teleport_player(checkpoints[cp].spawn_pos)
	checkpoints[cp].on_loaded_checkpoint.emit(0.0)
