class_name DEBUG
extends Node

const DEBUGGER_ENABLED: bool = true
var is_debugging: bool

var player: PlayerTest
var cam: Camera3D

@export var the_scenes: Array[PackedScene]

func _ready() -> void:
	_init_me()

func _process(delta: float) -> void:
	if !DEBUGGER_ENABLED:
		return
	if Input.is_action_just_pressed("_debug_open_console"):
		is_debugging = !is_debugging
		if is_debugging: $Console.visible = true
		else: $Console.visible = false

func _init_me() -> void:
	player = get_tree().get_first_node_in_group("Player") as PlayerTest
	print(get_tree().get_nodes_in_group("MainCamera"))
	cam = get_tree().get_first_node_in_group("MainCamera") as Camera3D

func freeze_player() -> void:
	if !player: return
	player.freeze = true

func unfreeze_player() -> void:
	if !player: return
	player.freeze = false

func teleport_player_to_coord(x: float, y: float, z: float) -> void:
	if !player: return
	player.movement.teleport_player_by_coords(Vector3(x, y, z))

func teleport_player_to_node(node_to_teleport_to : Node3D) -> void:
	if !player: return
	player.movement.teleport_player(node_to_teleport_to)

func change_scene(index: int) -> void:
	get_tree().change_scene_to_packed(the_scenes[index])

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Commands Stuff ↓

var noclip_enabled: bool

func noclip() -> void:
	noclip_enabled = !noclip_enabled
