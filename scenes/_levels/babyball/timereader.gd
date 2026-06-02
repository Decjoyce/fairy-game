extends Label

@export var timer: Timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if !timer.is_stopped():
	text = sec_to_mmss(timer.time_left)

func sec_to_mmss(total_seconds: float) -> String:
	var secs: float = fmod(total_seconds, 60.0)
	var mins: int = int(total_seconds/60) % 60
	var mmss: String = "%02d:%02.0f" % [mins, secs]
	return mmss
