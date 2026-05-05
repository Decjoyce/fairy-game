extends Timer

@export var new_wait_time: float

func start_me(sig: float) -> void:
	start()

func stop_me(sig: float) -> void:
	stop()

func set_wait_time_to_new() -> void:
	wait_time = new_wait_time
