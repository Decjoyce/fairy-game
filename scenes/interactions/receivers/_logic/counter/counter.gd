@icon("res://assets/_editor_icons/icon_logic.svg")
class_name Counter
extends Node

signal on_activated(sig: float) ## Emits once max count is reached
signal on_change(sig: float) ## Emits every incrementation - value is current/max
signal on_deactivated(sig: float) ## Emits once current count is equal to 0 

signal on_change_use_current_count(sig: float)

@export var begin_count: int = 0
@export var min_count: int = 0
@export var max_count: int = 2
var current_count: int = 0

@export var loop: bool = true

func _ready() -> void:
	current_count = begin_count

func add_count(sig: float) -> void:
	current_count += 1
	if current_count <= max_count:
		on_change.emit(float(current_count)/float(max_count - min_count))
		on_change_use_current_count.emit(float(current_count))
	
	if current_count == max_count:
		on_activated.emit(1)
	
	if loop and current_count > max_count:
		current_count = min_count
		on_change.emit(float(current_count)/float(max_count - min_count))
		on_change_use_current_count.emit(float(current_count))
		on_deactivated.emit(0)

func minus_count(sig: float) -> void:
	current_count -= 1
	
	if current_count == min_count:
		on_deactivated.emit(0)
	
	if loop and current_count < min_count:
		current_count = max_count
		on_activated.emit(1)
