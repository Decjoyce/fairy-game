class_name Bridge
extends Node3D

@export var opened: bool

@onready var anim_obj: AnimatedObject = $AnimatedObject
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if opened: fully_open_bridge()

func open_bridge(sig: float) -> void:
	anim_obj.play_animation(sig)
	opened = sig == 1

func fully_open_bridge(sig: float = 1.0) -> void:
	anim_player.play("bridge_open")
	opened = true

func close_bridge(sig: float = 0.0) -> void:
	anim_player.play("bridge_close")
	opened = false
