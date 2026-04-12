class_name SaveGameHandler
extends Node

signal on_saved_game
signal on_before_load_game
signal on_loaded_game

var world_root: Node3D

var is_loading: bool

var delay_before_reload: float = 1.4

const MAX_SAVE_COUNT: int = 3

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save_game"):
		save_game()
	elif Input.is_action_just_pressed("load_game"):
		load_game()
	elif Input.is_action_just_pressed("reset_vs"):
		load_scene_root(get_tree().current_scene.scene_file_path)
	#elif Input.is_action_just_pressed("ui_end"): load_scene_root("res://scenes/__playground_scenes/puzzles/ThrowingPuzzles/puzzle_throw_2.tscn")

func file_save(saved_game: SavedGame) -> void:
	var num_saves: int = 1
	var temp_file: Resource
	print("saving_file")
	for i in range(MAX_SAVE_COUNT, 0, -1):
		prints(i, "user://savegame_" + str(i) + ".tres")
		if i+1 > MAX_SAVE_COUNT: continue
		if FileAccess.file_exists("user://savegame_" + str(i) + ".tres"):
			prints("user://savegame_" + str(i) + ".tres", "- exists")
			DirAccess.rename_absolute("user://savegame_" + str(i) + ".tres", "user://savegame_" + str(i+1) + ".tres")
	ResourceSaver.save(saved_game, "user://savegame_1.tres")

func save_game() -> void:
	var saved_game: SavedGame = SavedGame.new()
	
	saved_game.current_scene = get_tree().current_scene.scene_file_path
	
	saved_game.time_saved_at = Time.get_datetime_string_from_system()
	
	var player_data: SavedData_Player = SavedData_Player.new()
	get_tree().call_group("Player", "on_save_game", player_data) 
	saved_game.player_data = player_data
	
	var saved_data: Array[SavedData] = []
	get_tree().call_group("PO", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	on_saved_game.emit()
	
	file_save(saved_game)
	print("saved_game")
	print(OS.get_data_dir())

var uid_list: Dictionary[String, Node] = {}

func load_game() -> void:
	if is_loading: return
	var saved_game: SavedGame = load("user://savegame_1.tres") as SavedGame
	
	EffectsPlayer.blur_out(1, delay_before_reload, 0, true)
	EffectsPlayer.saturize(0, delay_before_reload/2, -1,true)
	
	is_loading = true
	await get_tree().create_timer(delay_before_reload).timeout
	await load_scene_root(saved_game.current_scene)
	
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
	EffectsPlayer.blur_out(0, delay_before_reload, 1, true)
	EffectsPlayer.saturize(1, delay_before_reload, 0, true)
	is_loading = false
	on_loaded_game.emit()

func load_game_from_menu(scene_to_load: PackedScene) -> void:
	if is_loading: return
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	
	is_loading = true
	await load_scene_for_first_time(scene_to_load)
	
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
	EffectsPlayer.blur_out(0, 1, 1, true)
	EffectsPlayer.saturize(1, 1, 0, true)
	is_loading = false


func _load_non_native_objs(obj: SavedData) -> void:
	#prints(obj.uid, obj.scene_path)
	var scene = load(obj.scene_path) as PackedScene
	var restored_node = scene.instantiate()
	get_tree().current_scene.add_child(restored_node)
	for i in restored_node.get_children():
		if i is not PersistentObject: continue
		i.has_method("on_load_game")
		i.on_load_game(obj)

func load_scene_root(scene_to_load: String) -> void:
	if scene_to_load == get_tree().current_scene.scene_file_path: get_tree().reload_current_scene()
	else: get_tree().change_scene_to_file(scene_to_load)
	await get_tree().node_added
	world_root = get_tree().current_scene
	if !world_root.is_node_ready():
		await world_root.ready

func load_scene_for_first_time(scene_to_change_to: PackedScene) -> void:
	print("hey")
	get_tree().change_scene_to_packed(scene_to_change_to)
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
