extends Node3D

var team_red: Array[PlayerTest]
var team_blue: Array[PlayerTest]

@export var spawn_positions_red_holder: Node3D
@export var spawn_positions_blue_holder: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player_spawned.connect(on_player_spawned)

func _exit_tree() -> void:
	PlayerManager.player_spawned.disconnect(on_player_spawned)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_player_spawned(_player: PlayerTest, _index: int) -> void:
	var is_team_blue: bool = _index % 2 == 0
	if team_blue: 
		team_blue.append(_player)
		_player.movement.teleport_player(spawn_positions_blue_holder.get_children().front())
	else: 
		team_red.append(_player)
		_player.movement.teleport_player(spawn_positions_red_holder.get_children().front())
