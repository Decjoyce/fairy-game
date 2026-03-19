@icon("res://assets/_editor_icons/icon_item_b.svg")
class_name Grabbable_Item
extends Interactable

var is_grabbed: bool = false

@onready var rb: RigidBody3D = $"."

@export_group("Item Type")
@export var item_type: ItemType
@export var display_name: String
@export var keywords: String ## Separate keywords with ,

@export_group("Weight")
enum item_weight_types {WEIGHTLESS, LIGHT, MEDIUM, HEAVY}
@export var item_weight: item_weight_types ## Weightless = 0; Light = 1; Medium = 3; Heavy = 8

@export_group("Collision")
@export var col: CollisionShape3D
@export var grab_col: CollisionShape3D

@export_group("Grabbing")
@export var grabbed_offset: Vector2 = Vector2.ZERO
@export var grabbed_rotation: float = 0.0

@export_group("Throwing")
@export var throw_distance : float = 8.0
@export var throwing_offset: Vector2 = Vector2.ZERO
@export var throwing_rotation: float = 0.0

@export_group("Breaking")
@export var can_break: bool
@export var break_force: float = 35.0
@export var impact_type: int
@export var destroyed_item: Node3D
var item_spawn_on_destroyed: Grabbable_Item
@export var destroyed_audio: AudioStreamPlayer3D
var is_broken: bool

@export_group("Graphics")
@export var idle_graphics: Node3D
@export var grabbed_graphics: Node3D
@export var untouched_graphics: Node3D

@export_group("Audio")
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@export var base_volume: float = 1.0

var prev_velocity: Vector3

@onready var raycast: RayCast3D = $RayCast3D

var has_been_picked_up: bool

var non_scene_native: bool
var is_pooled: bool = false
var starting_pos: Vector3

var grabbed_hand: PlayerHand = null

func _ready() -> void:
	interaction_type = InteractTypes.GRAB_ITEM
	rb.body_entered.connect(_on_collide)
	prompt_text = tr("GRAB") + tr(display_name)
	starting_pos = global_position
	if item_type is ItemType_Breakable and !is_broken:
		var _item_to_spawn: PackedScene = item_type.get_item_to_spawn()
		if _item_to_spawn == null: return
		item_spawn_on_destroyed = _item_to_spawn.instantiate()
		destroyed_item.add_child(item_spawn_on_destroyed)
		item_spawn_on_destroyed.position = Vector3.UP * 0.75
		item_spawn_on_destroyed.disable_me()
		item_spawn_on_destroyed.non_scene_native = true
		item_spawn_on_destroyed.is_pooled = true
		item_spawn_on_destroyed.set_meta("uid", "[NONNATIVE]")

func _physics_process(delta: float) -> void:
	prev_velocity = rb.linear_velocity

func begin_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	if grabbed_graphics:
		if untouched_graphics: untouched_graphics.visible = false
		idle_graphics.visible = false
		grabbed_graphics.visible = true
	has_been_picked_up = true
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO
	grabbed_hand = hand

func interacting(sig: float = -1, hand: PlayerHand = null) -> void:
	pass

func end_interact(sig: float = -1, hand: PlayerHand = null) -> void:
	if grabbed_graphics: grabbed_graphics.visible = false
	idle_graphics.visible = true
	
	grabbed_hand = null
	rb.freeze = false
	rb.force_update_transform()
	rb.linear_velocity = Vector3.ZERO

# ↑ Interacting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Enabling/Disabling Stuff ↓

func enable_me() -> void:
	grab_col.set_deferred("disabled", false)
	col.set_deferred("disabled", false)
	rb.freeze = false
	rb.linear_velocity = Vector3.ZERO
	col.force_update_transform()
	rb.force_update_transform()

func disable_me()-> void:
	grab_col.set_deferred("disabled", true)
	col.set_deferred("disabled", true)
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO
	$AudioPlayer.stop()

# ↑ Enabling/Disabling Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Use Stuff ↓

func begin_using_item() -> void:
	pass

func using_item(arg) -> void:
	pass

func end_using_item() -> void:
	pass

# ↑ Use Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Throw Stuff ↓

var init_impact: bool

func throw(_throw_mult: float) -> void:
	if grabbed_graphics: grabbed_graphics.visible = false
	grabbed_hand = null
	idle_graphics.visible = true
	rb.linear_velocity = Vector3.ZERO
	rb.freeze = false
	var throw_force := throw_distance * _throw_mult
	throw_force = sqrt(throw_force * -2 * rb.get_gravity().y)
	#prints(_throw_mult, throw_distance * _throw_mult, throw_force)
	rb.apply_central_impulse(-global_basis.z * throw_force * rb.mass)
	rb.force_update_transform()

func throw_alt(_throw_mult: float, dir: Vector3) -> void:##[-]
	if grabbed_graphics: grabbed_graphics.visible = false
	#global_rotation = dir
	idle_graphics.visible = true
	rb.linear_velocity = Vector3.ZERO
	rb.freeze = false
	var throw_force := throw_distance * _throw_mult
	throw_force = sqrt(throw_force * -2 * rb.get_gravity().y)
	#prints(_throw_mult, throw_distance * _throw_mult, throw_force)
	rb.apply_central_impulse(dir * (throw_force/1.25) * rb.mass)
	rb.force_update_transform()

# ↑ Throw Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Break Stuff ↓

func _on_collide(body: Node) -> void:
	if !init_impact:
		init_impact = true
		return
	var current_force: float = prev_velocity.length_squared()
	#print(current_force)
	if current_force <= 0.5: return
	
	audio_player.volume_linear = current_force/120
	audio_player.play()
	
	if raycast.is_colliding():
		Impact_Manager.play_impact_at(raycast.get_collision_point(), impact_type, 0.5)
	else: Impact_Manager.play_impact_at(global_position, impact_type, 0.5)
	
	if can_break and current_force >= break_force:
		break_item()

func break_item() -> void:
	if !can_break: return
	if is_grabbed:
		assert(grabbed_hand, "YOU IDIOT!!!! YOU FORGOT TO ASSIGN A HAND SOMEWHERE SOMEHOW SOMEWHEN")
		grabbed_hand.force_stop_interacting("FREE", false)
	if destroyed_item:
		destroyed_item.reparent(get_tree().current_scene)
		destroyed_item.visible = true
		destroyed_audio.play()
		destroyed_item.global_position = raycast.get_collision_point()
		if item_spawn_on_destroyed: 
			item_spawn_on_destroyed.enable_me()
			item_spawn_on_destroyed.reparent(get_tree().current_scene)
			item_spawn_on_destroyed.is_pooled = false
	#disable_me()
	is_broken = true
	call_deferred("send_to_ether")

func send_to_ether() -> void:
	#reparent(OMT.destroyed_item_cell) ##temp
	global_position = OMT.destroyed_item_cell.global_position
	disable_me()
	#print("Dead")
	#call_deferred("queue_free")

# ↑ Break Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Ballybog Stuff ↓

var tween: Tween

func ballybog_throw(throw_force: float, hand_position: Vector3, direction: Vector3) -> void:
	begin_interact()
	
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", hand_position, 0.075)
	tween.tween_property(self, "global_rotation", direction, 0.1)
	await tween.finished
	
	throw(throw_force)

# ↑ Ballybog Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Weight Stuff ↓

func get_weight() -> float:
	match item_weight:
		0: return 0 # weightless
		1: return 1 # light
		2: return 3 # medium
		3: return 8 # heavy
		_: return 0

# ↑ Weight Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Debug Stuff ↓

func dbg_move_to_player() -> void:
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", Debug.player.global_position, 0.075)
	tween.tween_property(self, "global_rotation", Debug.player.global_rotation, 0.1)
