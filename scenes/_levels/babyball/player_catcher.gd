extends Area3D

@export var bb_ball: BabyballManager

func _ready() -> void:
	area_entered.connect(_on_player_entered)

func _on_player_entered(_p: Area3D) -> void:
	if _p.get_parent() is PlayerTest:
		bb_ball.reset_player_to_their_position(_p.get_parent())
