class_name EffectPlayer
extends Node

func _ready() -> void:
	pass

# ↑ Main Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Blur Effect ↓

var cur_blur_out_effect: Tween
@export var blur_out_effect: ColorRect
@onready var blur_out_mat: ShaderMaterial = blur_out_effect.material

func blur_out(progress: float, length: float, override_effect: bool = false) -> Tween:
	if cur_blur_out_effect and !override_effect: return
	progress = clampf(progress, 0, 1.0)
	cur_blur_out_effect = create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	cur_blur_out_effect.tween_property(blur_out_mat, "shader_parameter/progress", progress, length)
	return cur_blur_out_effect

# ↑ Blur Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Saturation Effect ↓

var cur_saturation_effect: Tween
@export var saturation_effect: ColorRect
@onready var saturation_mat: ShaderMaterial = saturation_effect.material

func saturize(amount: float, length: float, override_effect: bool = false, play_once: bool = false) -> Tween:
	if cur_saturation_effect and !override_effect: return
	saturation_effect.visible = true
	cur_saturation_effect = create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	cur_saturation_effect.tween_property(saturation_mat, "shader_parameter/saturation", amount, length)
	if play_once: cur_saturation_effect.finished.connect(close_saturation)
	return cur_blur_out_effect

func close_saturation() -> void:
	saturation_effect.visible = false
	cur_saturation_effect.finished.disconnect(close_saturation)
