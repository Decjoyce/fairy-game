class_name HandState_Paint
extends HandState

var is_painting: bool

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	hand_controller.joystick_movement(_delta)
	
	

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	pass

func exit() -> void:
	pass
