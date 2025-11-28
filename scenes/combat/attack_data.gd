class_name AttackData
extends Resource

@export var slot: int

@export var dmg: float
@export var stam: float

@export var telegraph_anim: String
@export var attack_anim: String
@export var recover_anim: String

@export var telegraph_audio: AudioStreamRandomizer
@export var attack_audio: AudioStreamRandomizer
@export var recover_audio: AudioStreamRandomizer

var full_attack_length: float
@export var telegraph_length: float
@export var attack_length: float
@export var recover_length: float

func get_full_attack_length() -> float:
	return telegraph_length + attack_length + recover_length
