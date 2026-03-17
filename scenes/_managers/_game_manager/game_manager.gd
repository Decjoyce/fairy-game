class_name GameManager
extends Node3D

var level_manager: LevelManager

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("Level") as LevelManager
	print(get_tree().current_scene)

var test_timer: float

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_vs"):
		if level_manager != null:
			load_last_checkpoint()

# ↑ Default Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Sequence Stuff ↓

func reset_level() -> void:
	level_manager = null
	get_tree().reload_current_scene()
	await get_tree().node_added
	level_manager = get_tree().current_scene
	if !level_manager.is_node_ready():
		await level_manager.ready

# ↑ Sequence Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checkpoint Stuff ↓

@export var cur_checkpoint: int = 0

func load_last_checkpoint() -> void:
	await reset_level()
	level_manager.load_checkpoint(cur_checkpoint)

func load_checkpoint(cp: int) -> void:
	await reset_level()
	cur_checkpoint = cp
	level_manager.load_checkpoint(cur_checkpoint)

func reached_checkpoint(cp: int) -> void:
	cur_checkpoint = cp

func reached_next_checkpoint() -> void:
	cur_checkpoint += 1
