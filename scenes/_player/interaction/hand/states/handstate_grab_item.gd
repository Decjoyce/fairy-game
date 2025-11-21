class_name HandState_Grab_Item
extends HandState

var is_ready: bool
var is_exiting: bool

var tween: Tween

@export var offset_helper: Control

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if is_exiting: return
	
	set_grab_position()
	
	hand_controller.joystick_movement(_delta)
	if Input.is_action_just_pressed("change_hand_speed_" + hand_controller.stringed_hand_type): hand_controller.change_hand_speed()
	
	if is_ready:
		if Input.is_action_just_pressed("action_" + hand_controller.stringed_hand_type):
			begin_charge()
	if Input.is_action_pressed("action_" + hand_controller.stringed_hand_type):
			charging(_delta)
	if is_charging and Input.is_action_just_released("action_" + hand_controller.stringed_hand_type):
			end_charge()
	
	if is_ready:
		grabbing()

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	grabbed_item = hand_controller.hovering_interactable
	
	_space_state = hand_controller.cam.get_world_3d().direct_space_state
	
	hand_controller.animation_player.play("a_hand_pickup")
	
	set_grab_position()
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(grabbed_item, "global_position", grab_position, 0.075)
	tween.tween_property(grabbed_item, "global_rotation", hand_controller.player.rotation, 0.1)
	
	await tween.finished
	hand_controller.animation_player.play("a_hand_idle_grab_item")
	is_ready = true
	time_held_down = 0

func exit() -> void:
	hand_controller.hovering_interactable = null
	is_ready = false
	tween.kill()
	#is_exiting = true
	#grabbed_item = null

# ↑ State Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Grabbing Stuff ↓

const GRAB_DIST = 1
var grabbed_item: Grabbable_Item
var grab_position: Vector3
@export_flags_2d_physics var grab_ray_collision_mask: int

var _space_state: PhysicsDirectSpaceState3D

func set_grab_position() -> void:
	var origin := hand_controller.cam.project_ray_origin(offset_helper.get_screen_position())
	var end := origin + hand_controller.cam.project_ray_normal(offset_helper.global_position) * GRAB_DIST
	
	var query := PhysicsRayQueryParameters3D.create(origin, end, grab_ray_collision_mask) # probably want to add layer stuff later
	query.collide_with_areas = true
	
	var result = _space_state.intersect_ray(query)
	
	if !result or !result.collider:
		grab_position = end
	else:
		#print(result.collider)
		grab_position = result.position + (result.normal * 0.1)

func grabbing() -> void:
	grabbed_item.global_position = grab_position
	grabbed_item.rotation = hand_controller.player.rotation

# ↑ Grabbing Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Charge Stuff ↓

var is_charging: bool 
var charge_amount: float
@export var delay_before_max_charge = 2
var time_held_down: float = 0.0

func begin_charge() -> void:
	is_charging = true
	charge_amount = 0
	time_held_down = 0
	hand_controller.animation_player.play("a_hand_grab_item_charge")
	
func charging(_delta: float) -> void:
	time_held_down += _delta
	var _charged_amount = time_held_down / delay_before_max_charge
	
	charge_amount = clampf(_charged_amount, 0.0, 1.0)

func end_charge() -> void:
	hand_controller.animation_player.play("a_hand_grab_item_throw")
	if charge_amount < 0.1: grabbed_item.end_interact()
	else: 
		grabbed_item.throw(charge_amount)
	
	is_charging = false
	charge_amount = 0
	time_held_down = 0
	
	finished.emit(FREE)
