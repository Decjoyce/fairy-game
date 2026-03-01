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
