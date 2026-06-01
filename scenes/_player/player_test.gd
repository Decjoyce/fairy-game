@icon("res://assets/_editor_icons/icon_player_b.svg")
class_name PlayerTest
extends Entity

@export var player_index: int
@export var testing_mode: bool

@onready var movement: PlayerMovement = $Movement
@onready var interaction: PlayerInteract = $Interaction
const PLAYER_HEIGHT: float = 1
const PLAYER_HEIGHT_CROUCHED: float = 0.65
@onready var current_player_height: float = PLAYER_HEIGHT
const PLAYER_WEIGHT: float = 10
@onready var cam: Camera3D = $Camera3D

@export var death_scene: PackedScene

@export var stats_ui: Control

var in_combat: bool
@export var combat: PlayerCombat

var freeze : bool

@export var death_ui: Control

@export var post_processing: Shader

@onready var local_effect_player: EffectPlayer = $LocalEffectPlayer

@export var babyball_mode: bool

@export var all_visuals: Array[MeshInstance3D]
@export var jersey: MeshInstance3D
@export var jersey_num: Label3D
@export var col: StaticBody3D
@export var compass: Node3D

var device: int

func set_up_mp(_p_index: int) -> void:
	player_index = _p_index
	device = _p_index
	jersey_num.text = str(_p_index)
	match _p_index:
		0:
			cam.set_cull_mask_value(6, false)
			jersey_num.set_layer_mask_value(6, true)
			col.set_collision_layer_value(6, true)
			for i in all_visuals:
				i.set_layer_mask_value(6, true)
			for j in compass.get_children():
				if j is not ShapeCast3D: continue
				j.set_collision_mask_value(6, false)
		1:
			cam.set_cull_mask_value(7, false)
			jersey_num.set_layer_mask_value(7, true)
			col.set_collision_layer_value(7, true)
			for i in all_visuals:
				i.set_layer_mask_value(7, true)
			for j in compass.get_children():
				if j is not ShapeCast3D: continue
				j.set_collision_mask_value(7, false)
		2:
			cam.set_cull_mask_value(8, false)
			jersey_num.set_layer_mask_value(8, true)
			col.set_collision_layer_value(8, true)
			for i in all_visuals:
				i.set_layer_mask_value(8, true)
			for j in compass.get_children():
				if j is not ShapeCast3D: continue
				j.set_collision_mask_value(8, false)
		3:
			cam.set_cull_mask_value(9, false)
			jersey_num.set_layer_mask_value(9, true)
			col.set_collision_layer_value(9, true)
			for i in all_visuals:
				i.set_layer_mask_value(9, true)
			for j in compass.get_children():
				if j is not ShapeCast3D: continue
				j.set_collision_mask_value(9, false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_weight = PLAYER_WEIGHT
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	if babyball_mode:
		interaction.enable_alt_throwing()
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_end"):
		#toggle_combat_new()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_combat() -> void:
	pass
	#in_combat = !in_combat
	#if in_combat: combat.enter_combat_mode()
	#else: combat.exit_combat_mode()

func toggle_combat_new() -> void:
	in_combat = !in_combat
	if in_combat: 
		interaction.force_stop_interacting("ATTACK", true, true)
	else: 
		interaction.force_stop_interacting("FREE", false, true)

func die():
	Debug.play_death_player()
	$Camera3D/DeathAnimationPlayer.play("death_anim")
	interaction.force_stop_interacting()
	interaction.visible = false
	death_ui.visible = true
	freeze = true
	stats_ui.visible = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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
	var d_scene: DeathScene = death_scene.instantiate() as DeathScene
	d_scene.set_graphics(stats.last_dmg_type)
	visible = false
	get_parent().add_child(d_scene)
	interaction.visible = false
	death_ui.visible = false
	$OmniLight3D.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if freeze: 
		return
	
	movement.rotate_input()
	
	movement.rotate(delta)
	
	if babyball_mode:
		movement.movement_babyball(delta)
		
		movement.movement_input_babyball()
	else:
	
		movement.movement(delta)
		
		movement.movement_input()
		movement.movement_input_sprint()

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

func no_more_crouch() -> void:
	movement.uncrouch()
	movement.restrict_crouch = true

var ending_override: bool
var trigged_ending: bool
func enable_ending_override() -> void:
	freeze = true
	interaction.enable_ending_stuff()
	$Camera3D/EndingAnim.play("ending_anim")
	EffectsPlayer.vignettize(0, 0, 1.0, 1, true, false)

func do_ending() -> void:
	get_tree().change_scene_to_file("res://scenes/_levels/Final_Puzzles/ENDING_SCENE/the_end_scene.tscn")
	#EffectsPlayer.close_vignettize()
