class_name AudioSigReceiver
extends Node

@export var audio_player: AudioStreamPlayer3D

func enable_audio_via_sig(sig:float) -> void:
	if !audio_player: return
	audio_player.play()

func disable_audio_via_sig(sig:float) -> void:
	if !audio_player: return
	audio_player.stop()

func enable_audio_via_obj(obj:Object) -> void:
	if !audio_player: return
	audio_player.play()

func disable_audio_via_obj(obj:Object) -> void:
	if !audio_player: return
	audio_player.stop()
