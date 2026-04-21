@icon("res://assets/_editor_icons/icon_gate.svg")
class_name Gate
extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

var is_opening: bool
var time_since_start: float = 0.0
var _start_position: float
var _end_position: float
var open_pos: float = 1.8
@export var speed: float = 0.5
@onready var graphics: Node3D = $gate
@onready var player_col: CollisionShape3D = $PlayerCollision/CollisionShape3D
@export var height_to_toggle_player_barrier: float = 0.7
@export var stay_open: bool
@export_group("IGNORE")
@export var tp_checker_col: CollisionShape3D
@export var out_pos_back: Node3D
@export var out_pos_front: Node3D
@onready var avp: AudioValuePlayer = $AudioValuePlayer
var current_out_pos: Vector3

var things_under: Array[Node3D]


var cur_value: float
var last_value: float

@export_category("Override Signal Range")
@export var override_signal_range: bool = false
@export_range(0, 0.9, 0.01) var ovr_signal_min: float = 0
@export_range(0, 1.0, 0.01) var ovr_signal_max: float = 1.0

var player_col_should_enabled: bool
var stop_player: bool

func open_gate(amount: float) -> void:
	if stay_open and cur_value >= 1: return
	if override_signal_range: 
		if amount < ovr_signal_min: amount = ovr_signal_min
		elif amount > ovr_signal_max: amount = ovr_signal_max
		#prints("before", amount)
		amount = remap(amount, ovr_signal_min, ovr_signal_max, 0, 1.0)
	time_since_start = 0
	is_opening = true
	_start_position = graphics.position.y
	#prints("open: ", amount)
	last_value = cur_value
	cur_value = amount
	_end_position = 1 + (open_pos * amount)
	
	check_if_disable_col(true)

func fully_open_gate(sig: float = -1) -> void:
	time_since_start = 0
	is_opening = true
	_start_position = graphics.position.y
	last_value = cur_value
	cur_value = 1
	_end_position = 1 + (open_pos * 1)
	
	check_if_disable_col()

func close_gate(sig: float = -1) -> void:
	time_since_start = 0
	is_opening = true
	_start_position = graphics.position.y
	last_value = cur_value
	cur_value = 0
	_end_position = 1 + (open_pos * 0)
	
	check_if_disable_col()

func toggle_gate(sig: float = -1) -> void:
	if cur_value > 0.5: close_gate()
	else: fully_open_gate()

func _process(delta: float) -> void:
	
	avp.play_me_bro(cur_value)
	
	if !things_under and player_col_should_enabled:
		player_col.set_deferred("disabled",false)
		tp_checker_col.set_deferred("disabled",false)
		player_col_should_enabled = false
	
	if is_opening:
		if (things_under and cur_value <= last_value): return
		#print(time_since_start)
		time_since_start += delta
		var percentage_complete = clamp(time_since_start / speed, 0, 1)
		#prints(length_to_complete, percentage_complete)
		
		graphics.position.y = gate_lerp(_start_position, _end_position, percentage_complete)
		
		if percentage_complete >= 1:
			is_opening = false
			#time_since_start = 0

func gate_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish

func check_if_disable_col(use_cur: bool = false) -> void:
	if use_cur:
		if cur_value >= height_to_toggle_player_barrier:
			player_col.set_deferred("disabled",true)
			tp_checker_col.set_deferred("disabled",true)
			player_col_should_enabled = false
			stop_player = false
		else:
			stop_player = true
			if things_under: 
				player_col.set_deferred("disabled",true)
				tp_checker_col.set_deferred("disabled",true)
				player_col_should_enabled = true
			else: 
				player_col.set_deferred("disabled",false)
				tp_checker_col.set_deferred("disabled",false)
	else:
		if _end_position >= open_pos + height_to_toggle_player_barrier:
			player_col.set_deferred("disabled",true)
			tp_checker_col.set_deferred("disabled",true)
			player_col_should_enabled = false
			stop_player = false
		else:
			stop_player = true
			if things_under: 
				player_col.set_deferred("disabled",true)
				tp_checker_col.set_deferred("disabled",true)
				player_col_should_enabled = true
			else: 
				stop_player = true
				player_col.set_deferred("disabled",false)
				tp_checker_col.set_deferred("disabled",false)



func tp_checker_entered(area: Area3D) -> void:
	var f = area.get_parent()
	if f is PlayerTest:
		f.movement.teleport_player_by_coords(current_out_pos)

func out_pos_area_entered_back(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		current_out_pos = out_pos_back.global_position

func out_pos_area_entered_front(area: Area3D) -> void:
	if area.get_parent() is PlayerTest:
		current_out_pos = out_pos_front.global_position

func _on_area_exited_under_checker(area: Area3D) -> void:
	if things_under.has(area.get_parent()):
		things_under.erase(area.get_parent())

func _on_area_entered_under_checker_player(area: Area3D) -> void:
	if  area.get_parent() is Entity: # removed:: = area.get_parent() is Grabbable_Item or
		things_under.append(area.get_parent())

func _on_body_entered_under_checker(body: Node3D) -> void:
	if body is Grabbable_Item or body is Entity:
		if body is Grabbable_Item:
			print("s")
			if body.is_grabbed: return
		things_under.append(body)

func _on_body_exited_under_checker(body: Node3D) -> void:
	if things_under.has(body):
		things_under.erase(body)
