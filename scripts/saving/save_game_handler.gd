class_name SaveGameHandler
extends Node

signal on_saved_game
signal on_before_load_game
signal on_loaded_game

var world_root: Node3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save_game"):
		save_game()
	elif Input.is_action_just_pressed("load_game"):
		load_game()

func save_game() -> void:
	var saved_game: SavedGame = SavedGame.new()
	
	var player_data: SavedData_Player = SavedData_Player.new()
	get_tree().call_group("Player", "on_save_game", player_data) 
	saved_game.player_data = player_data
	
	var saved_data: Array[SavedData] = []
	get_tree().call_group("PO", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	on_saved_game.emit()
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	print("saved_game")
	print(OS.get_data_dir())

var uid_list: Dictionary[String, Node] = {}

func load_game() -> void:
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	
	await reload_cur_scene()
	
	get_tree().call_group("Player", "on_before_load_game") 
	get_tree().call_group("Player", "on_load_game", saved_game.player_data) 
	
	on_before_load_game.emit()
	get_tree().call_group("PO", "on_before_load_game")
	
	uid_list.clear()
	for i in get_tree().get_nodes_in_group("PO"):
		assert(i is PersistentObject, "A node was marked as PO despite not being of type PersistentObject -- NOTIFY DECLAN ASAP")
		if i.get_parent().has_meta("uid"):
			uid_list[i.get_uid()] = i
	
	#print(uid_list)
	
	for obj in saved_game.saved_data:
		if !uid_list[obj.uid]:
			printerr("AN UID - Write A PROPER ERROR BRO - in SAVEGAMEHANDLER")
			continue
		if obj.uid == "[NONNATIVE]": # Nodes that were not placed in scene but spawned in after 
			_load_non_native_objs(obj)
		else: # Nodes that were originally placed in the scene
			if uid_list[obj.uid].has_method("on_load_game"):
				uid_list[obj.uid].on_load_game(obj)
	call_deferred("emit_on_loaded_game")

func _load_non_native_objs(obj: SavedData) -> void:
	#prints(obj.uid, obj.scene_path)
	var scene = load(obj.scene_path) as PackedScene
	var restored_node = scene.instantiate()
	get_tree().current_scene.add_child(restored_node)
	for i in restored_node.get_children():
		if i is not PersistentObject: continue
		i.has_method("on_load_game")
		i.on_load_game(obj)

func reload_cur_scene() -> void:
	get_tree().reload_current_scene()
	await get_tree().node_added
	world_root = get_tree().current_scene
	if !world_root.is_node_ready():
		await world_root.ready

func emit_on_loaded_game() -> void:
	on_loaded_game.emit()

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
