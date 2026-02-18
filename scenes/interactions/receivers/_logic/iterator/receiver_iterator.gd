extends Node

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@export var begin_count: int = 0
@export var max_count: int = 2
var current_count: int = 0

@export var loop: bool = true

func _ready() -> void:
	current_count = begin_count

func add_iteration(sig: float) -> void:
	current_count += 1
	on_change.emit(float(current_count)/float(max_count))
	
	if current_count == max_count:
		on_activated.emit(1)
	
	if loop and current_count > max_count:
		current_count = 0
		on_deactivated.emit(0)

func minus_iteration(sig: float) -> void:
	current_count -= 1
	
	if current_count == 0:
		on_deactivated.emit(0)
	
	if loop and current_count < 0:
		current_count = max_count
		on_activated.emit(1)
