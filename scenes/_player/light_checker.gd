class_name LightChecker
extends Node

#region DBG
@export_group("DebugStuff")
@export var dbg_ctrl: Control
@export var dbg_light_texture_front: TextureRect
@export var dbg_light_bar_front: ProgressBar
@export var dbg_light_texture_back: TextureRect
@export var dbg_light_bar_back: ProgressBar
@export var dbg_light_texture_combined: ColorRect
@export var dbg_light_bar_combined: ProgressBar
#endregion

@onready var par: Node3D = get_parent()

@onready var viewport_front: SubViewport = $_front
@onready var viewport_back: SubViewport = $_back

@onready var ld_front: Node3D = $_front/LightDetection_Front
@onready var ld_back: Node3D = $_back/LightDetection_Back


var current_light_level_front: float
var current_light_avgcolor_front: Color
var lerped_current_light_level_front: float
var lerped_current_light_avgcolor_front: Color

var current_light_level_back: float
var current_light_avgcolor_back: Color
var lerped_current_light_level_back: float
var lerped_current_light_avgcolor_back: Color

var current_light_level: float
var current_light_avgcolor: Color
var lerped_current_light: float
var lerped_current_light_avgcolor: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calc_light_values()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match_par_position()
	lerp_values(delta)
	
	if Engine.get_process_frames() % 24 != 0: return
	calc_light_values() 

func calc_light_values() -> void:
	update_front()
	update_back()
	#current_light_avgcolor = current_light_avgcolor_front.blend(current_light_avgcolor_back)
	current_light_avgcolor = (current_light_avgcolor_back + current_light_avgcolor_front)

	current_light_level = (current_light_level_front + current_light_level_back) 
	current_light_avgcolor = current_light_avgcolor.lightened(current_light_level * 0.5)
	
	dbg_light_bar_combined.value = current_light_level
	dbg_light_texture_combined.color = current_light_avgcolor

func update_front() -> void:
	var texture: ViewportTexture = viewport_front.get_texture()
	var color: Color = get_average_color(texture)
	current_light_avgcolor_front = color
	current_light_level_front = color.get_luminance()
	#dbg_light_bar_front.value = current_light_level_front
	#dbg_light_texture_front.texture = texture

func update_back() -> void:
	var texture: ViewportTexture = viewport_back.get_texture()
	var color: Color = get_average_color(texture)
	current_light_avgcolor_back = color
	current_light_level_back = color.get_luminance()
	#dbg_light_bar_back.value = current_light_level_back
	#dbg_light_texture_back.texture = texture

func lerp_values(delta: float) -> void:
	lerped_current_light = lerp(lerped_current_light, current_light_level, 200 * delta)
	lerped_current_light_avgcolor = lerp(lerped_current_light_avgcolor, current_light_avgcolor, 200 * delta)

func get_average_color(texture: ViewportTexture) -> Color:
	var image := texture.get_image()
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS)
	return image.get_pixel(0,0)

func match_par_position() -> void:
	ld_front.global_position = par.global_position
	ld_front.global_rotation = par.global_rotation
	ld_back.global_position = par.global_position
	ld_back.global_rotation = par.global_rotation
