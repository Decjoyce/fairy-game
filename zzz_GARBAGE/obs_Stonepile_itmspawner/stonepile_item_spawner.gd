class_name Stonepile_itemspawner
extends Node3D

## Something no good will happen when you hold item and look away from the pile. Item will still be in hand

var cam: Camera3D
@onready var item_mover: ItemMover = $ItemMover

var waiting_to_replace: bool 
var holding_stone: bool 

#@export var stones: Array[Grabbable_Item]

func _ready() -> void:
	await get_tree().root.ready
	cam = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if !waiting_to_replace or holding_stone: return
	if Engine.get_process_frames() % 10 != 0: return
	if !cam.is_position_in_frustum(global_position):
		replace_stone()

func on_taken_stone(sig: float) -> void:
	holding_stone = true
	if waiting_to_replace: return
	print("f")
	waiting_to_replace = true
	item_mover.cur_item_index = wrapi(item_mover.cur_item_index+1, 0, 1)
	item_mover.alt_move_item_from_index()

func on_drop_stone(sig: float) -> void:
	holding_stone = false

func replace_stone() -> void:
	waiting_to_replace = false
	item_mover.move_item_from_index()
