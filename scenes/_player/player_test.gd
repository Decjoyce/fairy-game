class_name PlayerTest
extends Entity

@onready var movement: PlayerMovement = $Movement
const PLAYER_HEIGHT: float = 1
const PLAYER_WEIGHT: float = 5
@onready var cam: Camera3D = $Camera3D

@onready var stats: Stats = $Stats

var in_combat: bool
@export var combatUI: Control
var hands_in_combat: int

var freeze : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_weight = PLAYER_WEIGHT

func die():
	Debug.play_death_player()


func change_to_combat()-> void:
	hands_in_combat+=1
	in_combat = true
	combatUI.visible = true

func exit_to_combat()-> void:
	hands_in_combat-=1
	if hands_in_combat <= 0:
		in_combat = false
		combatUI.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if freeze: 
		return
	movement.rotate_input()
	
	movement.rotate(delta)
	
	movement.movement(delta)
	
	movement.movement_input()
