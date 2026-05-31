extends Node

signal player_spawned(p: PlayerTest, i: int)

var players: Array[PlayerTest]

var split_screen_container: GridContainer 

var player_viewport_scene: PackedScene = preload("res://scenes/_levels/babyball/player_splitscreen_holder.tscn") 

const MAX_PLAYERS: int = 4

func _ready() -> void:
	split_screen_container = get_tree().get_first_node_in_group("SSC")
	#add_player()
	#add_player()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_crouch"):
		add_player()

func add_player() -> void:
	if players.size() == MAX_PLAYERS: return
	var new_player_screen: Node = player_viewport_scene.instantiate()
	split_screen_container.add_child(new_player_screen)
	
	
	var new_player: PlayerTest = new_player_screen.get_child(0).get_child(0)
	players.append(new_player)
	new_player.name = "Player_" + str(players.size())
	new_player.set_up_mp(players.size())
	
	if split_screen_container.columns == 1:
		split_screen_container.columns = 2
	player_spawned.emit(new_player, players.size())
