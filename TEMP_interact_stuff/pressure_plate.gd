class_name PressurePlate
extends Node3D

# Probably change this to a universal class that these inherits
signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

enum plate_states {DEACTIVATED, ACTIVATED, INBETWEEN}
var current_state: plate_states

var items_on_plate: Dictionary[Grabbable_Item, int]

@export var weight_to_activate: float
var current_weight: float

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Triggering Stuff ↓

func _on_body_entered_trigger(body: Node3D) -> void:
	if body is Grabbable_Item:
		item_entered_pressure_plate(body as Grabbable_Item)

func _on_body_exited_trigger(body: Node3D) -> void:
	if body is Grabbable_Item:
		item_exited_pressure_plate(body as Grabbable_Item)

func item_entered_pressure_plate(item: Grabbable_Item) -> void:
	if items_on_plate.has(item): return
	print("entered")
	items_on_plate[item] = item.item_weight
	check_weight()

func item_exited_pressure_plate(item: Grabbable_Item) -> void:
	if items_on_plate.has(item): items_on_plate.erase(item)
	check_weight()

# ↑ Triggering Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checking Stuff ↓

func check_weight() -> void:
	update_total_weight()
	animate_plate()
	if current_weight >= weight_to_activate: activate()
	elif current_weight < weight_to_activate and current_weight > 0: inbetween()
	else: deactivate()

func update_total_weight() -> int:
	var updated_weight: int = 0
	for item in items_on_plate:
		updated_weight += items_on_plate[item]
	current_weight = updated_weight
	return current_weight

# ↑ Checking Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Activating Stuff ↓

func activate() -> void:
	if current_state == plate_states.ACTIVATED: return
	on_activated.emit(current_weight / weight_to_activate)
	on_change.emit(current_weight / weight_to_activate)
	current_state = plate_states.ACTIVATED

func deactivate() -> void:
	if current_state == plate_states.DEACTIVATED: return
	on_deactivated.emit(0)
	on_change.emit(current_weight / weight_to_activate)
	current_state = plate_states.DEACTIVATED

func inbetween() -> void:
	if current_state == plate_states.INBETWEEN: return
	on_change.emit(current_weight / weight_to_activate)
	current_state = plate_states.INBETWEEN

# ↑ Activating Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Animating Stuff ↓

var is_lerping: bool
var time_move_started: float 
var _start_position: float
var _end_position: float
@export var deactivated_pos: float = -0.1
@export var _lerp_speed: float = 100
@onready var graphics: Node3D = $Graphics

func animate_plate() -> void:
	time_move_started = Time.get_ticks_msec()
	is_lerping = true
	_start_position = graphics.position.y
	var move_amount : float = current_weight / weight_to_activate
	_end_position = deactivated_pos * move_amount
	prints(current_weight, weight_to_activate, move_amount, _end_position)

func _process(delta: float) -> void:
	if is_lerping:
		var time_since_start := Time.get_ticks_msec() - time_move_started
		var length_to_complete = abs(_end_position - _start_position) / _lerp_speed
		var percentage_complete = clamp(time_since_start / _lerp_speed, 0, 1)
		#prints(length_to_complete, percentage_complete)
		
		graphics.position.y = plate_lerp(_start_position, _end_position, percentage_complete)
		
		if percentage_complete >= 1:
			is_lerping = false

func plate_lerp(start: float, finish: float, percentage: float):
	var _percentage = clampf(percentage, 0.0, 1.0)
	return (1-_percentage) * start + _percentage * finish
