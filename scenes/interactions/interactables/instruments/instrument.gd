class_name Instrument
extends Grabbable_Item

@export var music_player: AudioStreamPlayer3D
var playback: AudioStreamPlayback = null

@export var min_freq: float = 110 #880 #440.00
@export var max_freq: float = 207.65 #1661.22 #830.61
var phase: float = 0.0

var sample_hz: float = 1100.0
var pulse_hz: float = 440.0

func _fill_buffer():
	var increment = pulse_hz / sample_hz

	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1

func _ready() -> void:
	super()
	music_player.stream.mix_rate = sample_hz
	music_player.play()
	playback = music_player.get_stream_playback()
	#_fill_buffer()

func using_item(arg) -> void:
	if fmod(Time.get_ticks_msec() * 100, 400) < 0: return
	#prints("koko", arg[1])
	pulse_hz = arg[0] * arg[1]
	_fill_buffer()
