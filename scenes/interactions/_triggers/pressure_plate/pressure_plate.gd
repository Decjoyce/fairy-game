@icon("res://assets/_editor_icons/icon_pressureplate.svg")
class_name PressurePlate
extends Node3D

# Probably change this to a universal class that these inherits
signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

enum plate_states {DEACTIVATED, ACTIVATED, INBETWEEN}
var current_state: plate_states

var items_on_plate: Dictionary[Grabbable_Item, float]
var entities_on_plate: Dictionary[Node3D, float]

@onready var collision: StaticBody3D = $Graphics/Collision

@export_range(1.0, 25, 0.5) var weight_to_activate: float = 2.0
var current_weight: float
@export var always_emit_on_change: bool = false

var loading_locked: bool #used to stop pp triggering after loading

@onready var avp: AudioValuePlayer = $AudioValuePlayer

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Triggering Stuff ↓

func _on_body_entered_trigger(body: Node3D) -> void:
	if body is Grabbable_Item:
		item_entered_pressure_plate(body as Grabbable_Item)

func _on_body_exited_trigger(body: Node3D) -> void:
	if body is Grabbable_Item:
		item_exited_pressure_plate(body as Grabbable_Item)
	

func _on_area_entered_trigger(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent() is Entity:
		entity_entered_pressure_plate(area.get_parent() as Entity)

func _on_area_exited_trigger(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if !area: return
	if area.get_parent() is Entity:
		entity_exited_pressure_plate(area.get_parent() as Entity)

func item_entered_pressure_plate(item: Grabbable_Item) -> void:
	if items_on_plate.has(item): return
	#print("entered")
	items_on_plate[item] = item.get_weight()
	check_weight()
	if always_emit_on_change: emit_on_change()

func item_exited_pressure_plate(item: Grabbable_Item) -> void:
	if items_on_plate.has(item): items_on_plate.erase(item)
	#print("exited")
	check_weight()
	if always_emit_on_change: emit_on_change()

func entity_entered_pressure_plate(entity: Entity) -> void:
	if entities_on_plate.has(entity): return
	#print("entered")
	entities_on_plate[entity] = entity.current_weight
	entity.current_pressureplate = self
	check_weight()
	if always_emit_on_change: emit_on_change()

func entity_exited_pressure_plate(entity: Entity) -> void:
	#prints(entity, entity.current_pressureplate, self)
	if entity.current_pressureplate == self: entity.current_pressureplate = null
	if entities_on_plate.has(entity): entities_on_plate.erase(entity)
	#print("exited")
	check_weight()
	if always_emit_on_change: emit_on_change()

# ↑ Triggering Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Checking Stuff ↓

func change_weight_to_activate(new_weight: float) -> void:
	weight_to_activate = clampf(new_weight, 1, 25)
	check_weight()

func update_weight_of_entity(entity: Entity) -> void:
	entities_on_plate[entity] = entity.current_weight
	check_weight()

func check_weight() -> void:
	update_total_weight()
	animate_plate()
	if current_weight >= weight_to_activate: activate()
	elif current_weight < weight_to_activate and current_weight > 0: inbetween()
	else: deactivate()
	check_if_reached_saved_num()

func update_total_weight() -> float:
	var updated_weight: float = 0
	for item in items_on_plate:
		updated_weight += items_on_plate[item]
	for entity in entities_on_plate:
		updated_weight += entities_on_plate[entity]
	current_weight = updated_weight
	prints("OOOOOOOOOOOOOO", current_weight/weight_to_activate)
	avp.play_me_bro(clampf(current_weight/weight_to_activate, 0, 1))
	return current_weight

# ↑ Checking Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Activating Stuff ↓

func activate() -> void:
	if current_state == plate_states.ACTIVATED: return
	var weight_percent: float = clampf(current_weight / weight_to_activate, 0, 1)
	if !loading_locked:
		on_activated.emit(weight_percent)
		on_change.emit(weight_percent)
	current_state = plate_states.ACTIVATED

func deactivate() -> void:
	if current_state == plate_states.DEACTIVATED: return
	var weight_percent: float = clampf(current_weight / weight_to_activate, 0, 1)
	if !loading_locked:
		on_deactivated.emit(0)
		on_change.emit(weight_percent)
	current_state = plate_states.DEACTIVATED

func inbetween() -> void:
	if !always_emit_on_change: emit_on_change()
	current_state = plate_states.INBETWEEN

func emit_on_change() -> void:
	if loading_locked: return
	var weight_percent: float = clampf(current_weight / weight_to_activate, 0, 1)
	on_change.emit(weight_percent)

# ↑ Activating Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Animating Stuff ↓

var is_lerping: bool
var time_move_started: float 
var _start_position: float
var _end_position: float
const DEACTIVATED_HEIGHT: float = -0.05
@export_range(100, 1500, 100) var _lerp_speed: float = 1000
@onready var graphics: Node3D = $Graphics

func animate_plate() -> void:
	time_move_started = Time.get_ticks_msec()
	is_lerping = true
	_start_position = graphics.position.y
	var move_amount : float = clampf(current_weight / weight_to_activate, 0, 1)
	_end_position = DEACTIVATED_HEIGHT * move_amount
	#prints(current_weight, weight_to_activate, move_amount, _end_position)

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

# ↑ Animating Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Saving Stuff ↓

var saved_num_on_pressure_plate: int

func _ready() -> void:
	TEMPSaveGameHandler.on_before_load_game.connect(load_lock)
	#TEMPSaveGameHandler.on_loaded_game.connect(load_unlock)

func check_if_reached_saved_num() -> void:
	if saved_num_on_pressure_plate == get_num_on_plate():
		load_unlock()

func get_num_on_plate() -> int:
	return entities_on_plate.size() + items_on_plate.size()

func load_lock() -> void:
	#print("lck")
	loading_locked = true

func load_unlock() -> void:
	#print("unlck")
	loading_locked = false
