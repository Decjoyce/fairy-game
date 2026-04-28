extends Node

@export var node_to_do_follow: Node3D
var player: PlayerTest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	node_to_do_follow.global_position = player.global_position
	node_to_do_follow.global_rotation.y = player.global_rotation.y
