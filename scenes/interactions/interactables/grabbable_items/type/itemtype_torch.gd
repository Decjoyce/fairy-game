class_name ItemType_Torch
extends ItemType

@export_category("Health")
@export var stay_lit_forever: bool
@export var max_health: float = 300
@export var starting_health: float = -1

@export_category("Light")
@export var noise: NoiseTexture2D
#@export var light_colour_gradient: Gradient
@export var light_strength: float
@export_range(0.1, 1.0, 0.1) var flicker_frequency: float
