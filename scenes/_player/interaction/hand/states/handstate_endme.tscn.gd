class_name HandState_End
extends HandState

func enter(previous_state_path: String, data := {}) -> void:
	hand_controller.input_controls.visible = false
	hand_controller.animation_player.play("end_anim")
