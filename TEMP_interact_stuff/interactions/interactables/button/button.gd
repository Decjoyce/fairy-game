class_name InteractableButton
extends InteractableInstant

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var trigger_while_activated: bool
@export var manual_reset: bool
@export var delay_before_reset: float = 1.0

var activated: bool

func _ready() -> void:
	interaction_type = InteractTypes.INSTANT
	timer.wait_time = delay_before_reset

func begin_interact(sig: float = -1) -> void:
	if activated: return
	activate_button()

func _process(delta: float) -> void:
	if activated and !timer.is_stopped():
		var mapped_time_left := timer.time_left / timer.wait_time
		on_change.emit(mapped_time_left)

func activate_button() -> void:
	activated = true
	
	on_activated.emit(1)
	
	anim.play("button_activated")
	
	if delay_before_reset <= 0: 
		manual_reset = true
	else:
		timer.wait_time = delay_before_reset
		timer.start()

func deactivate_button(emit_signal: bool = true): 
	activated = false
	
	if emit_signal:
		on_deactivated.emit(0)
	
	anim.play("button_reset")

func _on_timer_timeout() -> void:
	deactivate_button()
