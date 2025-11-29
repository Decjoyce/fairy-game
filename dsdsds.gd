extends Node3D

@export var anim_pl: AnimationPlayer

@export var end_screen: PackedScene

func _ready() -> void:
	anim_pl.play("fade_in")

func to_menu():
	get_tree().change_scene_to_packed(end_screen)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.owner is PlayerTest:
		anim_pl.play("dd")
