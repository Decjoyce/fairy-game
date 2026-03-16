class_name AnimatedObject
extends Node

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var anim_to_play: String
@export var connnect_anim_player: Node
var anim_player: AnimationPlayer

var current_time: float

func _ready() -> void:
	update_anim_player(connnect_anim_player, anim_to_play)
	anim_player.current_animation = anim_to_play
	anim_player.play_section(anim_to_play, 0, 0.001)

func play_animation(sig: float) -> void:
	#print(sig)
	var mapped_time: float = remap(sig, 0, 1, 0, anim_player.get_animation(anim_to_play).length)
	
	if mapped_time > anim_player.current_animation_position:
		anim_player.play_section(anim_to_play, anim_player.current_animation_position, mapped_time)
	elif mapped_time < anim_player.current_animation_position:
		anim_player.play_section_backwards(anim_to_play, mapped_time, anim_player.current_animation_position)

func update_anim_player(new_anim_player, new_anim_to_play: String) -> void:
	if new_anim_player == null:
		printerr("ERROR: anim_player is null!!")
		return
	if new_anim_player is AnimationPlayer:
		anim_player = new_anim_player
	elif new_anim_player is Node:
		var anim_player_child = new_anim_player.get_node("AnimationPlayer")
		if anim_player_child:
			anim_player = anim_player_child as AnimationPlayer
		else: printerr("ERROR: " + new_anim_player.name + " does not containt an AnimationPlayer component")
