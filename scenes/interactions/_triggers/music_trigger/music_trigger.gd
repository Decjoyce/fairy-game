class_name MusicReceiver
extends Node3D

signal on_activated(sig: float)
signal on_change(sig: float)
signal on_deactivated(sig: float)

@onready var default_trigger: Area3D = $Trigger

@export var debug_mode: bool
@export var overwrite_trigger: Area3D

var cur_instruments: Array[Instrument]

@export var melodies: Array[Melody]
var current_melody: int
var cur_sequence: Array[int]
var cur_note: int
var needed_note: int

var activated: bool

func _ready() -> void:
	var trig: Area3D
	if overwrite_trigger: 
		overwrite_trigger.area_entered.connect(_on_instrument_entered)
		overwrite_trigger.area_exited.connect(_on_instrument_exited)
	else: 
		default_trigger.area_entered.connect(_on_instrument_entered)
		default_trigger.area_exited.connect(_on_instrument_exited)
	update_current_sequence()
	update_needed_note()

func update_needed_note() -> void:
	needed_note = cur_sequence[cur_note]

func update_current_sequence() -> void:
	cur_sequence = melodies[current_melody].sequence

func on_note_heard(note: int, instrument: Instrument) -> void:
	if activated: return
	prints("nn:", note, needed_note)
	if note == needed_note:
		correct_note()
	else: incorrect_note()
	on_change.emit(float(cur_note) / float(cur_sequence.size()))

func correct_note() -> void:
	prints("c_1", cur_note)
	cur_note += 1
	if cur_note >= cur_sequence.size():
		print("c_2")
		current_melody += 1
		if current_melody >= melodies.size(): 
			print("c_3")
			activate()
			return
		cur_note = 0
		update_current_sequence()
	update_needed_note()

func incorrect_note() -> void:
	prints("ic_1", cur_note)
	cur_note = 0
	update_needed_note()

func activate() -> void:
	activated = true
	on_activated.emit(1.0)


func _on_instrument_entered(body: Area3D) -> void:
	if activated: return
	if body.get_parent() is not Grabbable_Item: return
	var instr: Instrument = body.get_parent() as Instrument
	cur_instruments.append(instr)
	instr.on_played_note.connect(on_note_heard)

func _on_instrument_exited(body: Node3D) -> void:
	if body.get_parent() is not Grabbable_Item: return
	if !cur_instruments.has(body.get_parent()): return
	var instr: Instrument = cur_instruments[cur_instruments.find(body.get_parent())]
	instr.on_played_note.disconnect(on_note_heard)
	cur_instruments.erase(instr)
