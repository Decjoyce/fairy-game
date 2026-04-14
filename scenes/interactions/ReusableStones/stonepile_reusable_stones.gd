extends Area3D

@onready var my_stone: Grabbable_Item = $stonepile_stone
@onready var itm_mover: ItemMover = $ItemMover
@onready var timer: Timer = $Timer

var stone_inside: bool
var waiting_to_start: bool

@onready var g_on: Node3D = $_g_on
@onready var g_off: Node3D = $_g_off

func _process(delta: float) -> void:
	g_on.visible = stone_inside
	
	if waiting_to_start and !my_stone.is_grabbed:
		waiting_to_start = false
		timer.stop()
		timer.start()

func on_stone_entered_return_areas(body: Node3D) -> void:
	if body != my_stone: return
	stone_inside = true
	waiting_to_start = true

func on_stone_exited_return_areas(body: Node3D) -> void:
	if body != my_stone: return
	stone_inside = false
	waiting_to_start = false

func on_tp_timeout() -> void:
	if my_stone.is_grabbed or !stone_inside: 
		timer.stop()
		return
	my_stone.rb.linear_velocity = Vector3.ZERO
	itm_mover.move_all_items()
	timer.stop()
