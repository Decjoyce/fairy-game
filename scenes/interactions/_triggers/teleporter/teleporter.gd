extends Node3D

@export var out_pos: Node3D

func _teleport_item(body: Node3D) -> void:
	if body is Grabbable_Item:
		body.global_position = out_pos.global_position
		body.global_rotation = out_pos.global_rotation


func _teleport_entity(area: Area3D) -> void:
	if area.get_parent() is Entity:
		if area.get_parent() is PlayerTest:
			var p = area.get_parent() as PlayerTest
			p.movement.teleport_player(out_pos)

func teleport_player(sig: float) -> void:
	Debug.player.movement.teleport_player(out_pos)
	#Debug.player.interaction.force_stop_interacting()
