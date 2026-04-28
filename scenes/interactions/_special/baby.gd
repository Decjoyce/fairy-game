extends InteractableInstant

func begin_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	on_begin_interact.emit(1.0)
	hand.player.enable_ending_override()
	hand.input_controls.visible = false
