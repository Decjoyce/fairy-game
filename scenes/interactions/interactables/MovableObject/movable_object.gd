class_name MovableObject
extends InteractableInstant

@export var needs_two_hands: bool
var hands_occupied: int

#@onready var col_checker:= %_col_checker

@export var checkers: Array[ShapeCast3D]
@export var cols: Array[CollisionShape3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_collision()

func begin_hover(hand: PlayerHand = null) -> void:
	print("mama mia")
	hands_occupied+=1

func end_hover(hand: PlayerHand = null) -> void:
	print("mamssa")
	hands_occupied-=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	check_collision()

func on_entity_entered(area: Area3D) -> void:
	if area.get_parent() is not Entity: return
	var entity: Entity = area.get_parent()
	move_me(entity)

func check_collision()-> void:
	if hands_occupied >= 2:
		for c in 4:
			if checkers[c].is_colliding(): 
				cols[c].set_deferred("disabled", false)
			else: 
				if !cols[c].disabled: cols[c].set_deferred("disabled", true)
	else:
		for c in 4:
			if cols[c].disabled: cols[c].set_deferred("disabled", false)

func move_me(entity: Entity) -> void:
	var dir := (global_position.round() - entity.global_position.round()) * Vector3(1,0,1)
	dir = dir.normalized()
	global_position+=dir
	global_position.round()
