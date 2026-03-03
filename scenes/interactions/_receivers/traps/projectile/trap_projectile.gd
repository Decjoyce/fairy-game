extends Node3D

@export var projectile_pool: Array[ArrowProjectiles]
@onready var fire_point: Node3D = $_projectiles
@export var audio: AudioStreamPlayer3D
var cur_index: int

func trigger_trap(sig: float = -1) -> void:
	projectile_pool[cur_index].reset_proj()
	projectile_pool[cur_index].shoot()
	audio.play()
	cur_index += 1
	if cur_index >= projectile_pool.size(): cur_index = 0
	elif cur_index < 0: cur_index = projectile_pool.size() - 1
