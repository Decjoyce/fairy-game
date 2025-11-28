extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

var is_opening: bool
var time_since_start: float = 0.0
var _start_position: float
var _end_position: float
var closed_pos: float = 2
@export var speed: float = 0.5
@onready var graphics: Node3D = $gate
@onready var player_col: CollisionShape3D = $PlayerCollision/CollisionShape3D
@export var height_to_toggle_player_barrier: float = 0.01
@onready var under_checker: Area3D = $gate/UnderChecker

var things_under: Array[Node3D]

func open_gate(amount: float) -> void:
	time_since_start = 0
	is_opening = true
	_start_position = graphics.position.y
	prints("open: ", amount)
	_end_position = 1 + (closed_pos * amount)
	
	if _end_position >= closed_pos + height_to_toggle_player_barrier:
		player_col.set_deferred("disabled",true)
	else:
		player_col.set_deferred("disabled",false)

func _process(delta: float) -> void:
	if is_opening and !things_under:
		#print(time_since_start)
		time_since_start += delta
		var percentage_complete = clamp(time_since_start / speed, 0, 1)
		#prints(length_to_complete, percentage_complete)
		
		graphics.position.y = plate_lerp(_start_position, _end_position, percentage_complete)
		
		if percentage_complete >= 1:
			is_opening = false
			#time_since_start = 0

func plate_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish


func _on_area_entered_under_checker(area: Area3D) -> void:
	if area.get_parent() is Grabbable_Item or area.get_parent() is Entity:
		things_under.append(area.get_parent())

func _on_area_exited_under_checker(area: Area3D) -> void:
	if things_under.has(area.get_parent()):
		things_under.erase(area.get_parent())


func _on_body_entered_under_checker(body: Node3D) -> void:
	if body is Grabbable_Item or body is Entity:
		if body is Grabbable_Item:
			if body.is_grabbed: return
		things_under.append(body)

func _on_body_exited_under_checker(body: Node3D) -> void:
	if things_under.has(body):
		things_under.erase(body)


func _on_after_final_boss_pressure_plate_on_activated(sig: float) -> void:
	pass # Replace with function body.
