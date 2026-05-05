extends Area3D

@export var return_point: Node3D
@export var ap: AudioStreamPlayer3D
@export var ap_clip: AudioStream

func _on_body_entered(body: Node3D) -> void:
	print("hello")
	if body is Grabbable_Item and body.is_in_group("ABYSSRETURNER"):
		body.global_position = return_point.global_position
		body.global_rotation = return_point.global_rotation
		if !ap: return
		ap.stream = ap_clip
		ap.play()
		print("DEDED")
