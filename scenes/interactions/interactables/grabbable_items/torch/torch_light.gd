extends OmniLight3D

@export var torch_details: ItemType_Torch

var noise: NoiseTexture2D
var max_health: float
var current_health: float
var flicker_freq: float

var time_passed: float = 0.0

var is_dead: bool

func _ready() -> void:
	if torch_details.starting_health < 0: current_health = torch_details.max_health
	else: current_health = torch_details.starting_health
	max_health = torch_details.max_health
	noise = torch_details.noise
	flicker_freq = torch_details.flicker_frequency

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	var sampled_noise = abs(noise.noise.get_noise_1d(time_passed))
	light_energy = torch_details.light_strength * (current_health / max_health) * (torch_details.flicker_frequency + sampled_noise)
	
	if !torch_details.stay_lit_forever:
		current_health -= delta
	
	if !is_dead and current_health <= 0:
		is_dead = true
		visible = false
