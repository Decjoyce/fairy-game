extends Node

@export var std_piece_arm: Array[Node3D]
@export var std_piece_base: Array[Node3D]
@export var std_piece_head: Array[Node3D]

var da_stat: StatueQuest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	da_stat = get_tree().get_first_node_in_group("Statue")
	da_stat.on_piece_inserted_arm.connect(delete_stuff_arm)
	da_stat.on_piece_inserted_base.connect(delete_stuff_arm)
	da_stat.on_piece_inserted_head.connect(delete_stuff_arm)

func delete_stuff_arm(sig: float) -> void:
	for i in range(std_piece_arm.size()-1, -1):
		std_piece_arm[i].queue_free()
		std_piece_arm.pop_back()
	da_stat.on_piece_inserted_arm.disconnect(delete_stuff_arm)

func delete_stuff_base(sig: float) -> void:
	for i in range(std_piece_arm.size()-1, -1):
		std_piece_arm[i].queue_free()
		std_piece_arm.pop_back()
	da_stat.on_piece_inserted_base.disconnect(delete_stuff_arm)


func delete_stuff_head(sig: float) -> void:
	for i in range(std_piece_arm.size()-1, -1):
		std_piece_arm[i].queue_free()
		std_piece_arm.pop_back()
	da_stat.on_piece_inserted_head.disconnect(delete_stuff_arm)
