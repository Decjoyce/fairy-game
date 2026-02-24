class_name MusicReceiver
extends Node3D

@onready var default_trigger: Area3D = $Trigger

@export var debug_mode: bool
@export var overwrite_trigger: Area3D

var cur_instruments: Array[Instrument]

func _ready() -> void:
	var trig: Area3D
	if overwrite_trigger: 
		overwrite_trigger.body_entered.connect(_on_instrument_entered)
		overwrite_trigger.body_exited.connect(_on_instrument_exited)
	else: 
		default_trigger.body_entered.connect(_on_instrument_entered)
		default_trigger.body_exited.connect(_on_instrument_exited)

func on_note_heard(note: int, instrument: Instrument) -> void:
	prints("Heard Note - ", note, "from", instrument)

func _on_instrument_entered(body: Node3D) -> void:
	if body is not Instrument: return
	prints(body.name, "has entered")
	var instr: Instrument = body as Instrument
	cur_instruments.append(instr)
	instr.on_played_note.connect(on_note_heard)

func _on_instrument_exited(body: Node3D) -> void:
	if !cur_instruments.has(body): return
	prints(body.name, "has entered")
	var instr: Instrument = cur_instruments[cur_instruments.find(body)]
	instr.on_played_note.disconnect(on_note_heard)
