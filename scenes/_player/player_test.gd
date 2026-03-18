@icon("res://assets/_editor_icons/icon_player_b.svg")
class_name PlayerTest
extends Entity

@export var testing_mode: bool

@onready var movement: PlayerMovement = $Movement
@onready var interaction: PlayerInteract = $Interaction
const PLAYER_HEIGHT: float = 1
const PLAYER_HEIGHT_CROUCHED: float = 0.65
@onready var current_player_height: float = PLAYER_HEIGHT
const PLAYER_WEIGHT: float = 10
@onready var cam: Camera3D = $Camera3D

@onready var stats: Stats = $Stats
@export var stats_ui: Control

var in_combat: bool
@export var combat: PlayerCombat

var freeze : bool

@export var death_ui: Control

@export var post_processing: Shader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_weight = PLAYER_WEIGHT

func _process(delta: float) -> void:
	pass

func toggle_combat() -> void:
	in_combat = !in_combat
	if in_combat: combat.enter_combat_mode()
	else: combat.exit_combat_mode()


func die():
	Debug.play_death_player()
	combat.exit_combat_mode()
	interaction.visible = false
	death_ui.visible = true
	freeze = true
	stats_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

var fake_dies: int
func fake_die(fakestring: StringName):
	#if fake_dies == 0: 
		#fake_dies+=1
	#	return
	TEMPSaveGameHandler.load_game()
	stats.death_anim.play("death_anim")
	Debug.play_death_player()
	#combat.exit_combat_mode()
	interaction.visible = false
	death_ui.visible = true
	freeze = false
	stats_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/_levels/menus/death_menu/death_scene.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if freeze: 
		return
	movement.rotate_input()
	
	movement.rotate(delta)
	
	movement.movement(delta)
	
	movement.movement_input()

var temp_do_save_trans: bool
var temp_t: float
var tmep_yo: float = 1
#@onready var savetrans: ColorRect = %tempsavetrans
#@onready var savetransmat: ShaderMaterial = savetrans.material

func on_save_game(saved_data: SavedData_Player) -> void:
	#region General Data
	saved_data.current_weight = current_weight
	saved_data.freeze = freeze
	#endregion
	
	#region Movement Data
	saved_data.position = global_position
	saved_data.target_position = movement.target_pos
	saved_data.rotation = global_rotation
	saved_data.target_rotation = movement.target_rotation
	saved_data.is_crouching = movement.is_crouching
	#endregion
	#temp_do_save_trans = true
	#tmep_yo = 0.5

func on_before_load_game() -> void:
	pass

func on_load_game(saved_data: SavedData_Player) -> void:
	#region General Data
	current_weight = saved_data.current_weight
	freeze = saved_data.freeze
	#endregion
	
	#region Movement Data
	global_position = saved_data.position
	movement.target_pos = saved_data.target_position
	movement.compass.global_position = saved_data.target_position
	global_rotation = saved_data.rotation
	movement.target_rotation = saved_data.target_rotation
	movement.compass.global_rotation.y = saved_data.target_rotation
	if saved_data.is_crouching:
		movement.call_deferred("crouch", true)
	#endregion
	#savetransmat.set_shader_parameter("progress", 0)
	#temp_do_save_trans = true
	#tmep_yo = 0.5
