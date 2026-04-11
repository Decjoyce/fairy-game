extends Sprite3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	var ran_offset:= rng.randf_range(0, 0.2)
	anim_player.play_section("flame_on", ran_offset, -1, -1, 1.0, false)
