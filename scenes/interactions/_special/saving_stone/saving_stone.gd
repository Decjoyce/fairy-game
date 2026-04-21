class_name SavingStone
extends Interactable

@onready var hand_place_l: Decal = $%hand_place_l
@onready var hand_place_r: Decal = %hand_place_r
@onready var particles: GPUParticles3D = $Particles

@export var shine_gradient: GradientTexture1D

@export var charge_length: float = 1.5

signal on_saved(sig: float)

var l_val: float
var r_val: float

var l_charged: bool
var r_charged: bool

func end_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	r_val = 0
	l_val = 0
	if !l_charged or !r_charged: update_decal()
	l_charged = false
	r_charged = false

func charge_complete() -> void:
	particles.emitting = true
	on_saved.emit(1.0)
	TEMPSaveGameHandler.save_game()

func check_charged() -> bool:
	l_charged = l_val >= 1.0
	r_charged = r_val >= 1.0
	if r_charged and l_charged:
		charge_complete()
		return true
	else: return false

func update_val(hand: int, val: float) -> bool:
	if hand == 0: l_val = val
	else: r_val = val
	update_decal()
	return check_charged()

func update_decal() -> void:
	hand_place_l.modulate = shine_gradient.gradient.sample(l_val)
	hand_place_r.modulate = shine_gradient.gradient.sample(r_val)

func get_hand_place(hand: int) -> Decal:
	if hand == 0: return hand_place_l
	else: return hand_place_r
