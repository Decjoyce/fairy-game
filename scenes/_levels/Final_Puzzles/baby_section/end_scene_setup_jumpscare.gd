extends Node

var player :PlayerTest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func setup_jumpscare(sig: float = -1) -> void:
	player.enable_ending_override()
 
