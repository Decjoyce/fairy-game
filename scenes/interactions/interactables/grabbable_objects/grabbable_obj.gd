@tool
class_name Grabbable_Obj
extends Interactable

@export var requires_two_hands: bool
var grabbed_times: int

var is_grabbed: bool
var is_being_pulled: bool

@onready var col: StaticBody3D = $Collision

@onready var detect_dirs: Array[ShapeCast3D] = [$Detecters/North, $Detecters/South, $Detecters/West, $Detecters/East]

var last_pos: Vector3

func _process(delta: float) -> void:
	call_deferred("update_last_pos", delta)

func begin_interact(sig: float = -1) -> void:
	
	is_grabbed = true
	grabbed_times += 1
	if requires_two_hands and grabbed_times < 2:
		return
	
	for dirs in detect_dirs:
		dirs.enabled = true
	
	col.collision_layer = 2
	
	var rounded_pos:= global_position.round()
	global_position = Vector3(rounded_pos.x, global_position.y, rounded_pos.z)
	
	is_being_pulled = true

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	grabbed_times -= 1
	is_grabbed = grabbed_times > 0
	if requires_two_hands or grabbed_times <= 0: stop_being_pulled()

func stop_being_pulled() -> void:
	var direction = global_position - last_pos
	var rounded_pos: Vector3
	if direction > Vector3.ZERO: rounded_pos = global_position.floor()
	elif direction < Vector3.ZERO: rounded_pos= global_position.ceil()
	else: rounded_pos= global_position.round()
	
	global_position = Vector3(rounded_pos.x, global_position.y, rounded_pos.z)
	is_being_pulled = false
	
	for dirs in detect_dirs:
		dirs.enabled = false
	
	col.collision_layer = 1

func update_last_pos(delta) -> void:
	last_pos = global_position * delta

#var rounded_pos:= global_position.round()
#	global_position = Vector3(rounded_pos.x, global_position.y, rounded_pos.z)
