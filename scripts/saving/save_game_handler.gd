class_name SaveGameHandler
extends Node

@export var world_root: Node3D

#func _ready() -> void:
	#world_root = get_tree().get_first_node_in_group("mainscenetest")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save_game"):
		save_game()
	elif Input.is_action_just_pressed("load_game"):
		load_game()

func save_game() -> void:
	var saved_game: SavedGame = SavedGame.new()
	
	var saved_data: Array[SavedData] = []
	get_tree().call_group("PERSISTENT", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	print("saved_game")

func load_game() -> void:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	
	get_tree().call_group("PERSISTENT", "on_before_load_game")
	
	var uid_list: Dictionary[String, Node] = {}
	
	for i in get_tree().get_nodes_in_group("PERSISTENT"):
		assert(i.has("uid"), "A node was marked as PERSISTENT despite not containing a uid var -- NOTIFY DECLAN ASAP")
		uid_list[i.uid] = i
	
	print(uid_list)
	
	for obj in saved_game.saved_data:
		if obj is SavedDataItem:
			if !uid_list[obj.uid]:
				printerr("AN UID - RIGHT A PROPER ERROR BRO - in SAVEGAMEHANDLER")
				continue
			if uid_list[obj.uid].has_method("on_load_game"):
				uid_list[obj.uid].on_load_game(obj)





#region DUMP
# --------------------------------------------------------------------------------------------------
# ↓ DUMP ↑


#for obj in saved_game.saved_data:
		#if obj is SavedDataItem:
			#var scene = load(obj.scene_path) as PackedScene
			#var restored_node = scene.instantiate()
			#world_root.add_child(restored_node)
			#
			#if restored_node.has_method("on_load_game"):
				#restored_node.on_load_game(obj)
#endregion
