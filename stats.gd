class_name Stats
extends Node

var is_dead: bool

@export_category("Health")
@export var health_bar: ProgressBar
@export var max_health: float = 100
@export var current_health: float = -1

func take_damage(amount: float) -> bool:
	current_health -= amount
	if !is_dead and current_health <= 0:
		is_dead = true
		get_parent().queue_free() # change
	return is_dead

@export_category("Stamina")
@export var stam_bar: ProgressBar
@export var max_stamina: float = 100
@export var current_stamina: float = -1
@export var stamina_regen_rate: float = 2
var is_regen_stam: bool
@onready var stam_timer: Timer = $Timer 

func check_if_can_use_stam(amount: float) -> bool:
	if amount > current_stamina: return false
	else: return true

func take_stamina(amount: float) -> bool:
	if current_stamina <= 0: return false
	if amount > current_stamina: return false
	is_regen_stam = false
	current_stamina -= amount
	if current_stamina <= 0:
		stam_timer.wait_time = 3
		stam_timer.start()
		return false
	else:
		stam_timer.wait_time = 1.5
		stam_timer.start()
		return true

func _ready() -> void:
	if current_health < 0: current_health = max_health
	if current_stamina < 0: current_stamina = max_stamina
	health_bar.max_value = max_health
	health_bar.value = current_health
	stam_bar.max_value = max_stamina
	stam_bar.value = current_stamina

func _process(delta: float) -> void:
	if is_regen_stam:
		current_stamina += (delta * stamina_regen_rate)
		if current_stamina >= max_stamina:
			current_stamina = max_stamina
			is_regen_stam = false
	
	stam_bar.value = current_stamina
	health_bar.value = current_health

func begin_regen() -> void:
	is_regen_stam = true
