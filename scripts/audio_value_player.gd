class_name AudioValuePlayer
extends AudioStreamPlayer3D

@export var sounds: Array[AudioStream]
var last_sound: int

func _ready() -> void:
	play_me_bro(0.4)

func play_me_bro(val: float) -> void:
	var conv_val := floori(sounds.size() * val)-1
	if conv_val == last_sound: return
	last_sound = conv_val
	print(conv_val)
	stream = sounds[conv_val]
	play()
