class_name MassAudioSigReceiver
extends Node

@export var audio_players: Array[AudioStreamPlayer3D]

func enable_audio_via_sig(sig:float) -> void:
	for i in audio_players:
		i.play()

func disable_audio_via_sig(sig:float) -> void:
	for i in audio_players:
		i.stop()

func enable_audio_via_obj(obj:Object) -> void:
	for i in audio_players:
		i.play()

func disable_audio_via_obj(obj:Object) -> void:
	for i in audio_players:
		i.stop()
