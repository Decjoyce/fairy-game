@icon("res://assets/_editor_icons/icon_item_b.svg")
class_name Instrument
extends Grabbable_Item

@onready var timer: Timer = $Timer
@onready var timer_end: Timer = $timer_endnote
@export var music_player: AudioStreamPlayer3D
@onready var don: Node3D = $Particles
@export var music_particles: Array[GPUParticles3D]

signal on_played_note(note: int, instrument: Instrument)

var last_note_played: int
var is_playing: bool

var ending_note: bool

func begin_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	prints("ddd",don)
	super(sig, hand)
	

func end_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	super(sig, hand)
	if is_playing:
		end_sound()

func _process(delta: float) -> void:
	#music_particles.emitting = music_player.playing
	if is_playing: don.global_rotation = Vector3.ZERO
	
	if ending_note and timer_end.time_left > 0:
		music_player.volume_db = lerpf(music_player.volume_db, -100, (timer_end.time_left+0.5)/timer_end.wait_time * delta)
		#print(music_player.volume_db)
	elif ending_note:
		music_player.volume_db = 0
		music_player.stop()
		ending_note = false

func using_item(arg) -> void:
	if !is_grabbed: return
	if !is_playing:
		play_sound(arg[0])
	if is_playing and arg[0] != last_note_played:
		play_sound(arg[0])

func end_using_item(arg) -> void:
	timer.stop()
	#print("oof")
	end_sound()

func play_sound(note: int) -> void:
	prints("player played", note)
	ending_note = false
	timer_end.stop()
	if item_type is ItemType_Instrument:
		music_player.stream = item_type.get_note(note)
	music_player.volume_db = 0
	music_player.play()
	#timer.wait_time = music_player.stream.get_length()
	music_particles[last_note_played].emitting = false
	last_note_played = note
	music_particles[note].emitting = true
	on_played_note.emit(note, self)
	is_playing = true

func end_sound() -> void:
	music_particles[last_note_played].emitting = false
	timer_end.start()
	ending_note = true
	is_playing = false

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
