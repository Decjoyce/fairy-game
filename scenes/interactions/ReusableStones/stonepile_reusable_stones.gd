extends Area3D

@export var my_stone: Grabbable_Item
@export var copy_me_for_correct_pos: Vector3 = Vector3(0.0, 0.286, 0.0)
@onready var itm_mover: ItemMover = $ItemMover
@onready var timer: Timer = $Timer

var stone_inside: bool 
var waiting_to_start: bool

@onready var g_on: Node3D = $_g_on
@onready var g_waiting: Node3D = $_g_waiting
@onready var g_off: Node3D = $_g_off

@export var time_until_return: float = 2
@export var audio: AudioStreamPlayer3D

func _ready() -> void:
	timer.wait_time = time_until_return
	itm_mover.itms_2_move[0] = my_stone

func _process(delta: float) -> void:
	g_waiting.visible = my_stone.is_grabbed and !stone_inside
	g_on.visible = stone_inside
	my_stone.special_graphics.visible = stone_inside and !my_stone.is_grabbed
	my_stone.special_graphics.modulate.a = (timer.wait_time-timer.time_left)/timer.wait_time
	
	
	
	if waiting_to_start and !my_stone.is_grabbed:
		waiting_to_start = false
		timer.stop()
		timer.start()

func on_stone_area_entered_return_areas(area: Area3D) -> void:
	if area.get_parent() != my_stone: return
	#print("hey jude")
	stone_inside = false
	waiting_to_start = false

func on_stone_area_exited_return_areas(area: Area3D) -> void:
	if area.get_parent() != my_stone: return
	#print("buy jude")
	stone_inside = true
	waiting_to_start = true

#func on_stone_entered_return_areas(body: Node3D) -> void:
	#return
	#if body != my_stone: return
	#print("hey jude")
	#stone_inside = false
	#waiting_to_start = false
#
#func on_stone_exited_return_areas(body: Node3D) -> void:
	#return
	#if body != my_stone: return
	#print("buy jude")
	#stone_inside = true
	#waiting_to_start = true

func on_tp_timeout() -> void:
	if my_stone.is_grabbed or !stone_inside: 
		timer.stop()
		return
	stone_inside = true
	my_stone.rb.linear_velocity = Vector3.ZERO
	itm_mover.move_all_items()
	timer.stop()
	audio.play()
