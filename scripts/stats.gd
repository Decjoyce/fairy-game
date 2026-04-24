class_name Stats
extends Node

signal on_hit(new_health)
signal on_dead()

var is_dead: bool

func _ready() -> void:
	if current_health < 0: current_health = max_health

func _process(delta: float) -> void:
	regen_health(delta)

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Health Stuff ↓

@export_category("Health")
@export var max_health: float = 100
@export var current_health: float = -1
@export_group("Regen")
@export var can_regen_health: bool = false
@export var health_regen_rate: float = 2

@export_group("Fellow Nodes")
@export var who_owns: Node3D ## Who owns the stats - player or enemy
@export var hit_sfx: AudioStreamPlayer3D
@export var health_regen_timer: Timer

var is_regen_health: bool = true
var time_since_began_regen: float = 0

var last_dmg_type: int = -1

func take_damage(amount: float, damage_type: int = 0) -> bool:
	if is_dead: return true
	current_health -= amount
	last_dmg_type = damage_type
	if !check_if_dead():
		play_hit_fx()
		if can_regen_health: health_regen_timer.start()
	return is_dead

func heal(amount: float) -> void:
	if is_dead: return
	current_health += amount

func regen_health(delta: float) -> void:
	if is_regen_health:
		current_health += (delta * health_regen_rate)
		if current_health >= max_health:
			current_health = max_health
			is_regen_health = false

func begin_regen_health() -> void:
	is_regen_health = true

func check_if_dead() -> bool:
	if current_health <= 0:
		if !is_dead:
			is_dead = true
			who_owns.die()
		return true
	else: return false

func play_hit_fx() -> void:
	on_hit.emit(current_health)
	hit_sfx.play()
	# ↓ temp stuff ↓
	if !health_regen_timer: return
	var length = (max_health - current_health) / (health_regen_rate) + health_regen_timer.wait_time
	prints(current_health, length)
	var new_color: Color = Color.CRIMSON
	new_color.a = ((max_health - current_health)/max_health) * 0.8
	prints(Color.CRIMSON, new_color)
	owner.local_effect_player.colorize(new_color, new_color * Color.TRANSPARENT, length, true, true)

# ↑ Health Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ OBS Stamina Stuff ↓

#@export_category("Stamina")
#@export var stam_bar: ProgressBar
#@export var max_stamina: float = 100
#@export var current_stamina: float = -1
#@export var stamina_regen_rate: float = 2
#var is_regen_stam: bool
#@onready var stam_timer: Timer = $Timer 
#
#@export var stam_sfx: AudioStreamPlayer3D
#
#
#func check_if_can_use_stam(amount: float) -> bool:
	#if amount > current_stamina: return false
	#else: return true
#
#var out_of_stam: bool
#func take_stamina(amount: float) -> bool:
	#if current_stamina <= 0: return false
	##if amount > current_stamina: return false
	#is_regen_stam = false
	#current_stamina -= amount
	#if current_stamina <= 0:
		#stam_timer.wait_time = 5
		#out_of_stam = true
		#stam_timer.start()
		#stam_sfx.play()
		#return false
	#else:
		#stam_timer.wait_time = 3
		#stam_timer.start()
		#return true
#
#func begin_regen() -> void:
	#out_of_stam = false
	#is_regen_stam = true


#func _lerp_two(start: float, finish: float, percentage: float):
	#var _percentage = clampf(percentage, 0.0, 1.0)
	#return (1-_percentage) * start + _percentage * finish
