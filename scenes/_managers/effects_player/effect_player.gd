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

func saturize(amount: float, length: float, start_amount: float = -1, override_effect: bool = false, play_once: bool = false) -> Tween:
	if cur_saturation_effect and !override_effect: return
	if start_amount >= 0: saturation_mat.set_shader_parameter("saturation", start_amount)
	saturation_effect.visible = true
	cur_saturation_effect = create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	cur_saturation_effect.tween_property(saturation_mat, "shader_parameter/saturation", amount, length)
	if play_once: cur_saturation_effect.finished.connect(close_saturation)
	return cur_blur_out_effect

func close_saturation() -> void:
	saturation_effect.visible = false
	cur_saturation_effect.finished.disconnect(close_saturation)

# ↑ Blur Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Colorize Effect ↓

var cur_colorize_effect: Tween
@export var colorize_effect: ColorRect
@onready var colorize_mat: ShaderMaterial = colorize_effect.material

func colorize(from_color: Color, to_color: Color, length: float, override_effect: bool = false, play_once: bool = false) -> Tween:
	if cur_colorize_effect and !override_effect: return
	if override_effect and cur_colorize_effect and cur_colorize_effect.is_running(): cur_colorize_effect.stop()
	colorize_mat.set_shader_parameter("new_color", from_color)
	colorize_effect.visible = true
	cur_colorize_effect = create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD)
	cur_colorize_effect.tween_property(colorize_mat, "shader_parameter/new_color", to_color, length)
	if play_once: cur_colorize_effect.finished.connect(close_colorize)
	return cur_colorize_effect

func close_colorize() -> void:
	colorize_effect.visible = false
	cur_colorize_effect.finished.disconnect(close_colorize)
	cur_colorize_effect = null
