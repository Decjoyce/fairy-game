class_name ArrowProjectiles
extends CharacterBody3D

var graphics: Node3D
var col: ImprovedRaycast
var shot: bool
var speed: float = 20
var dir: Vector3
@export var offset: float = 0.01

func _ready() -> void:
	col = $_col
	graphics = $_graphics
	reset_proj()

func shoot(gen_new_dir: bool = true) -> void:
	#print("shot: proj")
	graphics.visible = true
	shot = true
	col.enabled = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	if gen_new_dir:
		var ran: RandomNumberGenerator = RandomNumberGenerator.new()
		var ran_dir: Vector3 = Vector3(ran.randf_range(-offset, offset), ran.randf_range(-offset, offset), ran.randf_range(-offset, offset))
		dir = (-global_basis.z + ran_dir)

func reset_proj(reset_pos: bool = true, hide_me: bool = true) -> void:
	#print("reset: proj")
	if reset_pos: position = Vector3.ZERO
	if hide_me: graphics.visible = false
	col.enabled = false
	shot = false
	process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	if !shot: return
	move_and_collide((dir * speed) * delta)

func _on_improved_raycast_on_body_entered(obj: Object) -> void:
	if obj.get_parent() is Entity:
		var stats: Stats = obj.get_parent().get_node("Stats") as Stats
		stats.take_damage(50)
		reset_proj()
	elif obj.get_parent() is Grabbable_Item: 
		var itm: Grabbable_Item = obj.get_parent() as Grabbable_Item
		if itm.can_break:
			itm.break_item()
		reset_proj()
	else:
		print(obj.name)
		reset_proj(false, false)
