extends Node3D

signal on_piece_inserted(piece: String)
signal on_stage_completed_sig(sig: float)
signal on_stage_completed(stage: int)
signal on_quest_completed(sig: float)

var stages: int = 3 # 0 = default, 1 = 1st piece added, 2 = 2nd piece added, 3 = 3rd piece added/completed
var current_stage: int

@export var temp_graphics__pieces: Array[Node3D]
@export var temp_graphics__unfinished_statue: Node3D
@export var temp_graphics__finished_statue: Node3D

func insert_piece(num_received: int, item_received: Grabbable_Item) -> void:
	current_stage = num_received
	print(item_received.keywords)
	match item_received.keywords:
		"BASE": piece_inserted_base()
		"HEAD": piece_inserted_head()
		"ARM": piece_inserted_arm()
		_: printerr(item_received, "contains invalid keyword for statue quest = ", item_received.keywords, " || Must be either BASE, HEAD, or ARM")
	
	on_stage_completed.emit(current_stage)
	on_stage_completed_sig.emit(current_stage/stages)
	
	if current_stage != 3: return
	quest_completed()


func piece_inserted_base() -> void:
	on_piece_inserted.emit("BASE")
	temp_graphics__pieces[0].visible = true

func piece_inserted_head() -> void:
	on_piece_inserted.emit("HEAD")
	temp_graphics__pieces[1].visible = true

func piece_inserted_arm() -> void:
	on_piece_inserted.emit("ARM")
	temp_graphics__pieces[2].visible = true

func quest_completed() -> void:
	on_quest_completed.emit(1)
	temp_graphics__unfinished_statue.visible = false
	temp_graphics__finished_statue.visible = true
