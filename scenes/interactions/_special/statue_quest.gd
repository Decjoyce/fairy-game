class_name StatueQuest
extends Node3D

signal on_piece_inserted(piece: String)
signal on_stage_completed_sig(sig: float)
signal on_stage_completed(stage: int)
signal on_quest_completed(sig: float)

signal on_piece_inserted_base(sig: float)
signal on_piece_inserted_arm(sig: float)
signal on_piece_inserted_head(sig: float)

var stages: int = 3 # 0 = default, 1 = 1st piece added, 2 = 2nd piece added, 3 = 3rd piece added/completed
var current_stage: int

@export var statue_pieces: Array[MeshInstance3D]
@export var itm_receiver: StatueReceiver

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func insert_piece(num_received: int, item_received: Grabbable_Item, emit_sigs: bool = true) -> void:
	current_stage = num_received
	print(item_received.keywords)
	
	var keywrd := item_received.keywords.split(";", false)[0]
	
	match keywrd:
		"BASE": piece_inserted_base(emit_sigs)
		"HEAD": piece_inserted_head(emit_sigs)
		"ARM": piece_inserted_arm(emit_sigs)
		_: printerr(item_received, "contains invalid keyword for statue quest = ", item_received.keywords, " || 1st Keyword Must be either BASE, HEAD, or ARM")
	
	if emit_sigs:
		on_stage_completed.emit(current_stage)
		on_stage_completed_sig.emit(float(current_stage)/float(stages))
	
	if current_stage != 3: return
	quest_completed()

func update_graphics() -> void:
	match current_stage:
		0: pass
		1: piece_inserted_arm(false)
		2: 
			piece_inserted_arm(false)
			piece_inserted_base(false)
		3: 
			piece_inserted_head(false)
			piece_inserted_arm(false)
			piece_inserted_base(false)
			quest_completed(true)

var insert_tween: Tween

func piece_inserted_base(emit_sigs: bool = true) -> void:
	if emit_sigs: 
		on_piece_inserted_base.emit(1.0)
		on_piece_inserted.emit("BASE")
	
	
	
	audio_player.play()
	
	statue_pieces[0].visible = true
	insert_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	insert_tween.set_ease(Tween.EASE_OUT_IN)
	insert_tween.tween_property(statue_pieces[0].material_overlay, "emission", Color.TRANSPARENT, 4)
	await insert_tween.finished
	statue_pieces[0].material_overlay = null


func piece_inserted_arm(emit_sigs: bool = true) -> void:
	if emit_sigs: 
		on_piece_inserted_arm.emit(1.0)
		on_piece_inserted.emit("ARM")
	
	
	
	audio_player.play()
	
	statue_pieces[1].visible = true
	insert_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	insert_tween.set_ease(Tween.EASE_IN)
	insert_tween.tween_property(statue_pieces[1].material_overlay, "emission", Color.TRANSPARENT, 4)
	await insert_tween.finished
	statue_pieces[1].material_overlay = null

func piece_inserted_head(emit_sigs: bool = true) -> void:
	if emit_sigs: 
		on_piece_inserted.emit("HEAD")
		on_piece_inserted_head.emit(1.0)
	
	
	
	audio_player.play()
	
	statue_pieces[2].visible = true
	insert_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	insert_tween.set_ease(Tween.EASE_IN)
	insert_tween.tween_property(statue_pieces[2].material_overlay, "emission", Color.TRANSPARENT, 4)
	await insert_tween.finished
	statue_pieces[2].material_overlay = null

func quest_completed(emit_sigs: bool = true) -> void:
	if emit_sigs: on_quest_completed.emit(1)
	statue_pieces[3].visible = true

func keywrd_checker(keywords: String) -> void:
	pass
