extends Node3D

@export var out_pos: Node3D

@export var do_not_rotate: bool

@export var disabled: bool

func _teleport_item(body: Node3D) -> void:
	if disabled: return
	if body is Grabbable_Item:
		body.global_position = out_pos.global_position
		if do_not_rotate: return
		body.global_rotation = out_pos.global_rotation


func _teleport_entity(area: Area3D) -> void:
	if disabled: return
	if area.get_parent() is Entity:
		if area.get_parent() is PlayerTest:
			var p = area.get_parent() as PlayerTest
			if do_not_rotate: p.movement.teleport_player_alt(out_pos.global_position)
			else: p.movement.teleport_player(out_pos)

func teleport_player(sig: float) -> void:
	get_tree().get_first_node_in_group("Player").movement.teleport_player(out_pos)
	#Debug.player.interaction.force_stop_interacting()

func enable_me(sig: float = 1.0) -> void:
	disabled = false

func disable_me(sig: float = 1.0) -> void:
	disabled = true
