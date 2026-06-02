class_name BabyballManager
extends Node3D

enum MatchStates {PRE_MATCH, MATCH, POST_MATCH}
var current_match_state: MatchStates

var team_red: Array[PlayerTest]
var team_blue: Array[PlayerTest]

var score_red: int
var score_blue: int

var score_to_win: int = 15

@export var spawn_positions_red_holder: Node3D
@export var spawn_positions_blue_holder: Node3D

@export var red_team_mat: Material
@export var blue_team_mat: Material

@export var red_score_label: Label
@export var blue_score_label: Label

@export var info_label: Label
@export var win_label: Label

@export var itm_mover: ItemMover

@export var game_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.player_spawned.connect(on_player_spawned)

func _exit_tree() -> void:
	PlayerManager.player_spawned.disconnect(on_player_spawned)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hide_text"): info_label.visible = !info_label.visible

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Functionality Stuff ↓

@export var prematch_stuff: Node3D

func reset_game(sig:float=-1) -> void:
	current_match_state = MatchStates.PRE_MATCH
	
	game_timer.timeout.disconnect(reset_game)
	
	prematch_stuff.visible = true
	prematch_stuff.global_position = Vector3.ZERO
	
	score_red = 0
	score_blue = 0
	
	reset_player_to_their_position_all()
	
	itm_mover.special_move_item_from_index()
	print("e")

func begin_game(sig:float=-1) -> void:
	if current_match_state == MatchStates.MATCH: return
	current_match_state = MatchStates.MATCH
	
	win_label.visible = false
	
	prematch_stuff.visible = false
	prematch_stuff.global_position = Vector3.UP * 50
	
	reset_player_to_their_position_all()
	
	PlayerManager.drop_all_items()
	itm_mover.special_move_item_from_index()
	
	PlayerManager.freeze_players()
	
	game_timer.wait_time = 3
	game_timer.start()
	game_timer.timeout.connect(fully_begin_game)

func fully_begin_game() -> void:
	PlayerManager.unfreeze_players()
	game_timer.wait_time = time_limit
	game_timer.start()
	game_timer.timeout.disconnect(fully_begin_game)
	game_timer.timeout.connect(check_who_won)
	print("f")

func end_game(sig:float=-1) -> void:
	if current_match_state == MatchStates.POST_MATCH: return
	current_match_state = MatchStates.POST_MATCH
	
	print("GAME OVER")
	
	game_timer.timeout.disconnect(check_who_won)
	
	game_timer.wait_time = 10
	game_timer.start()
	game_timer.timeout.connect(reset_game)

func check_who_won() -> void:
	if score_red >= score_to_win or score_red > score_blue: 
		win_label.text = "RED TEAM WINS"
		win_label.visible = true
		for i in team_red:
			i.crown.visible = true
			i.prev_crown.visible = false
			PlayerManager.prev_winners.append(i.player_index)
		end_game()
	elif score_blue >= score_to_win or score_blue > score_red: 
		win_label.text = "BLUE TEAM WINS"
		win_label.visible = true
		for i in team_blue:
			i.crown.visible = true
			i.prev_crown.visible = false
			PlayerManager.prev_winners.append(i.player_index)
		end_game()
	else:
		win_label.text = "TIE"
		win_label.visible = true
		end_game()

# ↑ Functionality Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Time Stuff ↓

var time_limit: float = 90

func increase_time_limit_by_ten(sig:float=-1) -> void:
	time_limit+=10

func decrease_time_limit_by_ten(sig:float=-1) -> void:
	time_limit-=10

func increase_time_limit_by_thirty(sig:float=-1) -> void:
	time_limit+=30

func decrease_time_limit_by_thirty(sig:float=-1) -> void:
	time_limit-=30

# ↑ Time Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Gamemode Stuff ↓

var use_items: bool

func toggle_use_items(sig: float = -1) -> void:
	use_items = !use_items

# ↑ Gamemode Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Score Stuff ↓

func increase_score_to_win(sig:float=-1) -> void:
	score_to_win+=1

func decrease_score_to_win(sig:float=-1) -> void:
	score_to_win-=1

func add_score_red(_points: int) -> void:
	itm_mover.special_move_item_from_index()
	if current_match_state != MatchStates.MATCH: return
	score_red+= _points
	red_score_label.text = str(score_red)


func add_score_blue(_points: int) -> void:
	itm_mover.special_move_item_from_index()
	if current_match_state != MatchStates.MATCH: return
	
	score_blue+= _points
	blue_score_label.text = str(score_blue)
	check_who_won()

func remove_score_blue(_points: int) -> void:
	score_blue-= _points
	blue_score_label.text = str(score_blue)
	#itm_mover.special_move_item_from_index()

func remove_score_red(_points: int) -> void:
	score_red-= _points
	blue_score_label.text = str(score_red)
	#itm_mover.special_move_item_from_index()

# ↑ Score Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Team Stuff ↓

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

func on_player_removed(_player: PlayerTest, _index: int) -> void:
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

func reset_player_to_their_position(_p: PlayerTest) -> void:
	if team_blue.has(_p): _p.movement.teleport_player(spawn_positions_blue_holder.get_child(team_blue.find(_p)))
	elif team_red.has(_p): _p.movement.teleport_player(spawn_positions_red_holder.get_child(team_red.find(_p)))

func reset_player_to_their_position_all() -> void:
	for b in team_blue.size():
		prints("dd", b)
		team_blue[b].movement.teleport_player(spawn_positions_blue_holder.get_child(b))
	for r in team_red.size(): 
		team_red[r].movement.teleport_player(spawn_positions_red_holder.get_child(r))

# ↑ Team Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Venue Stuff ↓

@export var venues: Node3D
@export var venue_disabler_helper: Node3D
var current_venue: Node3D
var current_venue_index: int
var current_venue_name: String

func change_venue_increase(sig:float=-1) -> void:
	var old_venue: Node3D = venues.get_child(current_venue_index)
	old_venue.visible = false
	old_venue.global_position = venue_disabler_helper.global_position
	current_venue_index=wrapi(current_venue_index+1, 0, venues.get_child_count())
	current_venue = venues.get_child(current_venue_index)
	current_venue.visible = true
	current_venue.position = Vector3.ZERO
	current_venue_name = current_venue.name

func change_venue_decrease(sig:float=-1) -> void:
	var old_venue: Node3D = venues.get_child(current_venue_index)
	old_venue.visible = false
	old_venue.global_position = venue_disabler_helper.global_position
	current_venue_index=wrapi(current_venue_index-1, 0, venues.get_child_count())
	current_venue = venues.get_child(current_venue_index)
	current_venue.visible = true
	current_venue.position = Vector3.ZERO
	current_venue_name = current_venue.name
