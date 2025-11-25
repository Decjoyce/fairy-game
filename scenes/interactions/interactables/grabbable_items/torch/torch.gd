class_name Torch
extends Grabbable_Item

var current_health: float

var time_passed: float = 0.0

var is_dead: bool

@onready var torch_light: OmniLight3D = %TorchLight

var is_at_edge_of_screen: bool

var grav_scale: float
@export var sconted: bool
@export var scont: Torch_Scont


func _ready() -> void:
	if item_type is not ItemType_Torch:
		printerr("TORCH item type must of type torch")
		return
	if item_type.starting_health < 0: current_health = item_type.max_health
	else: current_health = item_type.starting_health
	if !is_dead and current_health == 0:
		die()
	if sconted:
		grav_scale = rb.gravity_scale
		rb.gravity_scale = 0

func begin_interact(sig: float = -1) -> void:
	super()
	if sconted:
		rb.gravity_scale = grav_scale
		visible = true
		sconted = false
		scont.disable_me()
		scont = null
		reparent(get_tree().current_scene)

func _process(delta: float) -> void:
	if is_dead or item_type.stay_lit_forever: return
	time_passed += delta
	
	var sampled_noise = abs(item_type.noise.noise.get_noise_1d(time_passed))
	torch_light.light_energy = item_type.light_strength * (current_health / item_type.max_health) * (item_type.flicker_frequency + sampled_noise)
	
	if has_been_picked_up:
		current_health -= delta
	
	if !is_dead and current_health <= 0:
		die()

func relight() -> void:
	current_health = item_type.max_health
	is_dead = false

func die() -> void:
	if !is_dead: return
	is_dead = true
	visible = false
