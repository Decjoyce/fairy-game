@tool
class_name PO_Button
extends PersistentObject

@onready var parent_button: InteractableButton = get_parent()

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	
	var my_data := SavedData_Button.new()
	my_data.uid = get_parent().get_meta("uid")
	my_data.disabled = parent_button.disabled
	my_data.activated = parent_button.activated
	my_data.time_left = parent_button.timer.time_left
	my_data.delay_before_reset = parent_button.delay_before_reset
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	if saved_data is SavedData_Button:
		if saved_data.disabled:
			parent_button.disable()
		parent_button.delay_before_reset = saved_data.delay_before_reset
		parent_button.activated = saved_data.activated
		if parent_button.activated == true:
			if !parent_button.manual_reset:
				parent_button.timer.wait_time = saved_data.time_left
				parent_button.timer.start()
			parent_button.anim.play("button_activated")
