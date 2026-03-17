extends Node3D

signal on_piece_inserted(piece: String)
signal on_stage_completed_sig(sig: float)
signal on_stage_completed(stage: int)
signal on_quest_completed(sig: float)

var stages: int = 3 # 0 = default, 1 = 1st piece added, 2 = 2nd piece added, 3 = 3rd piece added/completed
var current_stage: int

@export var statue: Sprite3DBillBoard

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
	statue.animation = 1

func piece_inserted_head() -> void:
	on_piece_inserted.emit("HEAD")
	statue.animation = 3

func piece_inserted_arm() -> void:
	on_piece_inserted.emit("ARM")
	statue.animation = 2

func quest_completed() -> void:
	on_quest_completed.emit(1)
	
