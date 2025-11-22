extends Node

const DEBUGGER_ENABLED: bool = true
var is_debugging: bool

var player: PlayerTest
var cam: Camera3D

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

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Commands Stuff ↓

var noclip_enabled: bool
