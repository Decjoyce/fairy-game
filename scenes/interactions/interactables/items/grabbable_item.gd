@icon("res://assets/_editor_icons/icon_item.svg")
@tool
class_name Grabbable_Item
extends Interactable

var is_grabbed: bool = false

@onready var rb: RigidBody3D = $"."

@export_category("Item Type")
@export var item_type: ItemType
@export var display_name: String

@export_category("Weight")
enum item_weight_types {WEIGHTLESS, LIGHT, MEDIUM, HEAVY}
@export var item_weight: item_weight_types

@export_category("Collision")
@export var col: CollisionShape3D
@export var grab_col: CollisionShape3D

@export_category("Grabbing")
@export var grabbed_offset: Vector2 = Vector2.ZERO
@export var grabbed_rotation: float = 0.0

@export_category("Throwing")
@export var throw_distance : float = 8.0
@export var throwing_offset: Vector2 = Vector2.ZERO
@export var throwing_rotation: float = 0.0
@export var can_break: bool
@export var break_force: float = 35.0
@export var destroyed_item: Node3D
var item_spawn_on_destroyed: Grabbable_Item
@export var destroyed_audio: AudioStreamPlayer3D

@export_category("Graphics")
@export var idle_graphics: Node3D
@export var grabbed_graphics: Node3D
@export var untouched_graphics: Node3D

@export_category("Audio")
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@export var base_volume: float = 1.0

var prev_velocity: Vector3

@onready var raycast: RayCast3D = $RayCast3D

var has_been_picked_up: bool
var non_scene_native: bool

func _ready() -> void:
	interaction_type = InteractTypes.GRAB_ITEM
	rb.body_entered.connect(_on_collide)
	prompt_text = tr("GRAB") + tr(display_name)
	if item_type is ItemType_Breakable:
		var _item_to_spawn: PackedScene = item_type.get_item_to_spawn()
		if _item_to_spawn == null: return
		item_spawn_on_destroyed = _item_to_spawn.instantiate()
		destroyed_item.add_child(item_spawn_on_destroyed)
		item_spawn_on_destroyed.position = Vector3.UP * 0.75
		item_spawn_on_destroyed.disable_me()

func _physics_process(delta: float) -> void:
	prev_velocity = rb.linear_velocity

func begin_interact(sig: float = -1) -> void:
	if grabbed_graphics:
		if untouched_graphics: untouched_graphics.visible = false
		idle_graphics.visible = false
		grabbed_graphics.visible = true
	has_been_picked_up = true
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO

func interacting(sig: float = -1) -> void:
	pass

func end_interact(sig: float = -1) -> void:
	if grabbed_graphics: grabbed_graphics.visible = false
	idle_graphics.visible = true
	
	rb.freeze = false
	rb.force_update_transform()
	rb.linear_velocity = Vector3.ZERO

func enable_me() -> void:
	grab_col.set_deferred("disabled", false)
	col.set_deferred("disabled", false)
	rb.freeze = false
	rb.linear_velocity = Vector3.ZERO
	col.force_update_transform()
	rb.force_update_transform()
	super()

func disable_me()-> void:
	grab_col.set_deferred("disabled", true)
	col.set_deferred("disabled", true)
	rb.freeze = true
	rb.linear_velocity = Vector3.ZERO
	$AudioPlayer.stop()
	super()

# ↑ Interacting Stuff ↑
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
# ↓ Item Stuff ↓

var init_impact: bool

func throw(_throw_mult: float) -> void:
	if grabbed_graphics: grabbed_graphics.visible = false
	idle_graphics.visible = true
	rb.linear_velocity = Vector3.ZERO
	rb.freeze = false
	var throw_force := throw_distance * _throw_mult
	throw_force = sqrt(throw_force * -2 * rb.get_gravity().y)
	#prints(_throw_mult, throw_distance * _throw_mult, throw_force)
	rb.apply_central_impulse(-basis.z * throw_force * rb.mass)
	rb.force_update_transform()

func _on_collide(body: Node) -> void:
	if !init_impact:
		init_impact = true
		return
	var current_force: float = prev_velocity.length_squared()
	#print(current_force)
	if current_force <= 0.5: return
	
	audio_player.volume_linear = current_force/120
	print(audio_player.volume_linear)
	audio_player.play()
	
	
	if raycast.is_colliding():
		Impact_Manager.play_impact_at(raycast.get_collision_point(), 0, 0.5)
	else: Impact_Manager.play_impact_at(global_position, 0, 0.5)
	
	if can_break and current_force >= break_force:
		break_item()

func break_item() -> void:
	if !can_break: return
	if destroyed_item:
		destroyed_item.reparent(get_tree().current_scene)
		destroyed_item.visible = true
		destroyed_audio.play()
		destroyed_item.global_position = raycast.get_collision_point()
		if item_spawn_on_destroyed: 
			item_spawn_on_destroyed.enable_me()
			item_spawn_on_destroyed.reparent(get_tree().current_scene)
	queue_free()

# ↑ Item Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Saving Stuff ↓

func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedDataItem.new()
	my_data.position = global_position
	my_data.scene_path = scene_file_path
	my_data.velocity = rb.linear_velocity
	
	
	saved_data.append(my_data)

func on_before_load_game() -> void:
	get_parent().remove_child(self)
	queue_free()

func on_load_game(saved_data: SavedData):
	global_position = saved_data.position
	if saved_data is SavedDataItem: 
		var my_data: SavedDataItem = saved_data as SavedDataItem
		rb.linear_velocity = my_data.velocity
