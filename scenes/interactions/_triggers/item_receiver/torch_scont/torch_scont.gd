class_name Torch_Scont
extends ItemReceiver

@onready var torch: Torch

#var disabled: bool


func disable_me() -> void:
	disabled = true
	visible = false
	col.disabled = true
