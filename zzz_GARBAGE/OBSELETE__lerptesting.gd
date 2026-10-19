extends Node3D

var time_taken_during_lerp: float = 5000
var distance_to_move: float = 5
var _is_lerping: bool = false

var _start_pos: Vector3
var _end_pos: Vector3

var _time_started_lerping: float

func start_lerping():
	_is_lerping = true
	_time_started_lerping = Time.get_ticks_msec()
	
	_start_pos = global_position
	_end_pos = global_position + Vector3.FORWARD*distance_to_move

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		start_lerping()

func _physics_process(delta: float) -> void:
	if _is_lerping:
		var time_since_start := Time.get_ticks_msec() - _time_started_lerping
		var percentage_complete : = time_since_start / time_taken_during_lerp
		
		var yo = lerp_me(_start_pos, _end_pos, percentage_complete)
		print(percentage_complete)
		global_position = yo
		
		if percentage_complete >= 1.0:
			_is_lerping = false

func lerp_me(start: Vector3, end: Vector3, percentage: float) -> Vector3:
	var _percentage = clampf(percentage, 0.0, 1)
	var start_to_finish = end - start
	return (1-_percentage)*start + _percentage*end
