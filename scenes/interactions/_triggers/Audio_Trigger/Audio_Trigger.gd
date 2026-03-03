extends Area3D

@export var audio_player: AudioStreamPlayer3D
@export var one_shot: bool = true  

var has_played: bool = false

func _ready():  
	if audio_player:
		audio_player.stop()


func _on_body_entered(body):
	if has_played and one_shot:
		return
	if body.is_in_group("Player"):
		audio_player.play()
		has_played = true 
