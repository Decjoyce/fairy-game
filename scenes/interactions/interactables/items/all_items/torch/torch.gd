@icon("res://assets/_editor_icons/icon_torch.svg")
class_name Torch
extends Grabbable_Item

var current_health: float

var time_passed: float = 0.0

var is_dead: bool

@onready var torch_light: OmniLight3D = %TorchLight

var is_at_edge_of_screen: bool

@export var sconted: bool

var collision_fix: bool
var col_fix_two: int

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
		collision_fix = true

func _process(delta: float) -> void:
	if is_dead: return
	
	time_passed = wrapf(time_passed+delta, 0.0, 10.0)
	var sampled_noise = abs(item_type.noise.noise.get_noise_1d(time_passed))
	torch_light.light_energy = item_type.light_strength * (item_type.flicker_frequency + sampled_noise)

func _physics_process(delta: float) -> void:
	super(delta)
	if col_fix_two == 1:
		rb.force_update_transform()
		rb.freeze = true
		collision_fix = false
		col_fix_two = -1
	if collision_fix: col_fix_two += 1 ## Stops the torch from colliding when grabbed after mounted

func relight() -> void:
	current_health = item_type.max_health
	is_dead = false

func die() -> void:
	if !is_dead: return
	is_dead = true
	visible = false
