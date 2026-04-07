class_name LightChecker
extends SubViewport

@onready var par: Node3D = get_parent()
@onready var light_detection: Node3D = $LightDetection
@export var dbg_light_texture: TextureRect
@export var dbg_light_bar: ProgressBar

var current_light_level: float
var current_light_avgcolor: Color
var lerped_current_light_level: float
var lerped_current_light_avgcolor: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_draw = Viewport.DEBUG_DRAW_LIGHTING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	light_detection.global_position = par.global_position
	light_detection.global_rotation = par.global_rotation
	lerped_current_light_level = lerp(lerped_current_light_level, current_light_level, 12 * delta)
	lerped_current_light_avgcolor = lerp(lerped_current_light_avgcolor, current_light_avgcolor, 120 * delta)
	
	if Engine.get_process_frames() % 60 != 0: return
	var texture: ViewportTexture = get_texture()
	var color: Color = get_average_color(texture)
	current_light_avgcolor = color
	current_light_level = color.get_luminance()
	dbg_light_bar.value = current_light_level
	dbg_light_texture.texture = texture

func get_average_color(texture: ViewportTexture) -> Color:
	var image := texture.get_image()
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS)
	return image.get_pixel(0,0)
