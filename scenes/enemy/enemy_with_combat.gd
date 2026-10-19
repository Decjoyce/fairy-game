class_name EnemyBB
extends CharacterBody3D

@export var player: PlayerTest

signal on_die(sig: float)

@onready var sm: NodeStateMachine = $StateMachine

@export var hear_length: float = 5

var last_heard_location: Vector3

func _ready() -> void:
	OMT.on_item_broke.connect(heard_noise)

func die() -> void:
	on_die.emit(1.0)
	Debug.death_audio_enemy.play()
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	print("ji")
	if body is Grabbable_Item:
		if body.prev_velocity.length() > 5:
			sm.transition_to("stunned")

func heard_noise(location: Vector3) -> void:
	prints("Hey i heard something! - ", location, global_position.distance_to(location))
	if global_position.distance_to(location) < hear_length:
		last_heard_location = location
		sm.current_node_state.on_heard_something(location)
