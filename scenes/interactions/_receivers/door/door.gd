@icon("res://assets/_editor_icons/icon_door_c.svg")
class_name Door
extends Node3D

@onready var anim_player: AnimationPlayer = $StaticBody3D/AnimationPlayer

@export var opened: bool
@export var opened_special: bool

func _ready() -> void:
	if opened: start_opened()
	if opened_special: open_door(-1)

func open_door(sig: float) -> void:
	anim_player.play("door_open")
	opened = true

func close_door(sig: float) -> void:
	anim_player.play("door_close")
	opened = false

func toggle_door(sig: float) -> void:
	if opened: close_door(0)
	else: open_door(1.0)

func start_opened() -> void:
	anim_player.play("door_open", -1, 20)

#func open_door(sig: float) -> void:
	#var mapped_time: float = remap(sig, 0, 1, 0, anim_player.get_animation("door_open").length)
	#
	#if mapped_time > anim_player.current_animation_position:
		#anim_player.play_section(anim_to_play, anim_player.current_animation_position, mapped_time)
	#elif mapped_time < anim_player.current_animation_position:
		#anim_player.play_section_backwards("door_open", mapped_time, anim_player.current_animation_positi)
