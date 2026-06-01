extends Node3D

var team_red: Array[PlayerTest]
var team_blue: Array[PlayerTest]

var score_red: int
var score_blue: int

@export var spawn_positions_red_holder: Node3D
@export var spawn_positions_blue_holder: Node3D

@export var red_team_mat: Material
@export var blue_team_mat: Material

@export var red_score_label: Label
@export var blue_score_label: Label

@export var info_label: Label

@export var itm_mover: ItemMover

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player_spawned.connect(on_player_spawned)

func _exit_tree() -> void:
	PlayerManager.player_spawned.disconnect(on_player_spawned)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hide_text"): info_label.visible = !info_label.visible

func add_score_red(_points: int) -> void:
	score_red+= _points
	red_score_label.text = str(score_red)
	itm_mover.move_item_from_index()

func add_score_blue(_points: int) -> void:
	score_blue+= _points
	blue_score_label.text = str(score_blue)
	itm_mover.move_item_from_index()

func on_player_spawned(_player: PlayerTest, _index: int) -> void:
	print(_index)
	var is_team_blue: bool = _index % 2 == 0
	print(is_team_blue)
	if is_team_blue: 
		team_blue.append(_player)
		_player.jersey.material_override = blue_team_mat
		
		await get_tree().create_timer(0.5).timeout
		_player.movement.teleport_player(spawn_positions_blue_holder.get_child(team_blue.size()-1))
	else: 
		team_red.append(_player)
		_player.jersey.material_override = red_team_mat
		
		await get_tree().create_timer(0.5).timeout
		_player.movement.teleport_player(spawn_positions_red_holder.get_child(team_red.size()-1))
