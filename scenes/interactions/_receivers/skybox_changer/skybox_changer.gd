extends Node

@export var world_environment: WorldEnvironment
@export var skybox_a: Environment
@export var skybox_b: Environment

func _ready() -> void:
	world_environment.environment = skybox_a

func change_to_a(sig: float) -> void:
	world_environment.environment = skybox_a

func change_to_b(sig: float) -> void:
	world_environment.environment = skybox_b
