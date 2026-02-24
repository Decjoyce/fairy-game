class_name Instrument
extends Grabbable_Item

@onready var timer: Timer = $Timer
@export var music_player: AudioStreamPlayer3D

signal on_played_note(note: int, instrument: Instrument)

func using_item(arg) -> void:
	if timer.is_stopped():
		play_sound(arg[0], arg[1])
		timer.start()

func play_sound(note: int, octave: float) -> void:
	prints(note, octave)
	music_player.pitch_scale = (octave + 1)/2
	if item_type is ItemType_Instrument:
		music_player.stream = item_type.get_note(note)
	music_player.play()
	on_played_note.emit(note, self)

# --------------------------------------------------------------------------------------------------
# ↓ Obs Stuff ↓
#@export var music_player: AudioStreamPlayer3D
#var playback: AudioStreamPlayback = null
#
#@export var min_freq: float = 110 #880 #440.00
#@export var max_freq: float = 207.65 #1661.22 #830.61
#var phase: float = 0.0
#
#var sample_hz: float = 1100.0
#var pulse_hz: float = 440.0
#
#@onready var timer: Timer = $Timer
#
#func _fill_buffer():
	#var increment = pulse_hz / sample_hz
#
	#var to_fill = playback.get_frames_available()
	#while to_fill > 0:
		#playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		#phase = fmod(phase + increment, 1.0)
		#to_fill -= 1
#
#func _ready() -> void:
	#super()
	#music_player.stream.mix_rate = sample_hz
	#music_player.play()
	#playback = music_player.get_stream_playback()
	#
	##_fill_buffer()
#
#func using_item(arg) -> void:
	#if timer.is_stopped():
		#play_sound(arg[0], arg[1])
		#timer.start()
#
#func play_sound(hz: float, octave: float) -> void:
	#pulse_hz = hz * octave
	#print(pulse_hz)
	#_fill_buffer()
