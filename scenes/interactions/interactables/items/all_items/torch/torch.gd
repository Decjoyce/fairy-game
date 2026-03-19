@icon("res://assets/_editor_icons/icon_torch.svg")
class_name Torch
extends Grabbable_Item

var current_health: float

var time_passed: float = 0.0

var is_dead: bool

@onready var torch_light: OmniLight3D = %TorchLight

var is_at_edge_of_screen: bool

@export var sconted: bool

func _ready() -> void:
	super()
	if item_type is not ItemType_Torch:
		printerr("TORCH item type must of type torch")
		return
	if sconted:
		rb.linear_velocity = Vector3.ZERO
		rb.freeze = true

func begin_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	super()
	if sconted:
		rb.freeze = false
		sconted = false

func _process(delta: float) -> void:
	if is_dead: return
	time_passed = wrapf(time_passed+delta, 0.0, 10.0)
	
	var sampled_noise = abs(item_type.noise.noise.get_noise_1d(time_passed))
	#torch_light.light_energy = clamp(item_type.light_strength * (current_health / item_type.max_health) * (item_type.flicker_frequency + sampled_noise), 0, item_type.light_strength)
	
	torch_light.light_energy = item_type.light_strength * (item_type.flicker_frequency + sampled_noise)
	#print(item_type.light_strength * (item_type.flicker_frequency + sampled_noise))
	#if has_been_picked_up:
		#current_health -= delta
	#
	#if !is_dead and current_health <= 0:
		#die()

func relight() -> void:
	current_health = item_type.max_health
	is_dead = false

func die() -> void:
	if !is_dead: return
	is_dead = true
	visible = false
