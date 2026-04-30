extends Node

@export var std_piece_arm: Array[Node3D]
@export var std_piece_base: Array[Node3D]
@export var std_piece_head: Array[Node3D]

var da_stat: StatueQuest

signal echo_piece_insert_arm(sig:float)
signal echo_piece_insert_base(sig:float)
signal echo_piece_insert_head(sig:float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	da_stat = get_tree().get_first_node_in_group("Statue")
	da_stat.on_piece_inserted_arm.connect(delete_stuff_arm)
	da_stat.on_piece_inserted_base.connect(delete_stuff_base)
	da_stat.on_piece_inserted_head.connect(delete_stuff_head)

func delete_stuff_arm(sig: float) -> void:
	echo_piece_insert_arm.emit(1.0)
	for i in range(std_piece_arm.size()-1, -1, -1):
		print("arm")
		std_piece_arm[i].queue_free()
		std_piece_arm.pop_back()
	da_stat.on_piece_inserted_arm.disconnect(delete_stuff_arm)

func delete_stuff_base(sig: float) -> void:
	echo_piece_insert_base.emit(1.0)
	for i in range(std_piece_base.size()-1, -1, -1):
		print("base")
		std_piece_base[i].queue_free()
		std_piece_base.pop_back()
	da_stat.on_piece_inserted_base.disconnect(delete_stuff_base)


func delete_stuff_head(sig: float) -> void:
	echo_piece_insert_head.emit(1.0)
	for i in range(std_piece_head.size()-1, -1, -1):
		print("head")
		std_piece_head[i].queue_free()
		std_piece_head.pop_back()
	da_stat.on_piece_inserted_head.disconnect(delete_stuff_head)
