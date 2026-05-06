class_name ItemType_Instrument
extends ItemType

@export var note_sound_files: Array[AudioStream]
#@export var note_sound_files_end: Array[AudioStream]

func get_note(note: int) -> AudioStream: 
	return note_sound_files[note]
