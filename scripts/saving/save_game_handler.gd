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
	
	print("loading_game")
	
	get_tree().call_group("PERSISTENT", "on_before_load_game")
	
	for obj in saved_game.saved_data:
		print("dayman")
		var scene = load(obj.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		world_root.add_child(restored_node)
		
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(obj)
	print("loaded_game")
