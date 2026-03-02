extends Node3D

@export var stage_indicators: Array[Sprite3D]

func _ready() -> void:
	for si in stage_indicators:
		si.visible = false

func stage_completed(stage: int) -> void:
	stage_indicators[stage - 1 ].visible = true
