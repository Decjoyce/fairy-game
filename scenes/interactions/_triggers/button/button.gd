@icon("res://assets/_editor_icons/icon_button.svg")
class_name InteractableButton
extends InteractableInstant

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var delay_before_reset: float = 1.0
@export var manual_reset: bool
@export var start_activated: bool = false

var activated: bool

func _ready() -> void:
	interaction_type = InteractTypes.INSTANT
	timer.wait_time = delay_before_reset
	if start_activated: activate_button()

func begin_interact(sig: float = -1) -> void:
	if disabled: return
	activate_button()

func _process(delta: float) -> void:
	if activated and !timer.is_stopped():
		var mapped_time_left := timer.time_left / delay_before_reset
		on_change.emit(mapped_time_left)

func activate_button() -> void:
	if disabled: return
	if activated: return
	activated = true
	
	on_activated.emit(1)
	
	anim.play("button_activated")
	
	if delay_before_reset <= 0: manual_reset = true
	
	if !manual_reset:
		timer.wait_time = delay_before_reset
		timer.start()

func deactivate_button(emit_a_signal: bool = true): 
	if disabled: return
	activated = false
	
	if emit_signal:
		on_deactivated.emit(0)
	
	anim.play("button_reset")

func reset_button(sig: float = -1) -> void:
	deactivate_button()

func change_delay(new_delay: float) -> void:
	delay_before_reset = new_delay
	timer.wait_time = new_delay

func _on_timer_timeout() -> void:
	timer.wait_time = delay_before_reset
	deactivate_button()


func _on_item_entered(area: Area3D) -> void:
	print("hmm")
	if area.get_parent() is Grabbable_Item:
		var rb = area.get_parent().rb as RigidBody3D
		print(rb.linear_velocity.length_squared())
		if rb.linear_velocity.length_squared() > 1:
			activate_button()
