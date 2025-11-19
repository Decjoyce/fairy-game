class_name PlayerTest
extends Entity

@onready var movement: PlayerMovement = $Movement
const PLAYER_HEIGHT: float = 1
const PLAYER_WEIGHT: float = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_weight = PLAYER_WEIGHT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	movement.rotate_input()
	
	movement.rotate(delta)
	
	movement.movement(delta)
	
	movement.movement_input()
