# Not ours - got from https://pastebin.com/AQm9adaq
## Via ~ How to make SPLATOON In Godot 4 ~ https://www.youtube.com/watch?v=4DFpLnEnKFk
### By ~ Crigz Vs Game Dev
class_name DrawViewport
extends SubViewport
 
@onready var brush: Node2D = $Brush
 
func paint(position : Vector2, colour: Color = Color(1, 1, 1)):
	#print("taint")
	brush.queue_brush(position * 1024, colour)

func clearme():
	render_target_clear_mode = ClearMode.CLEAR_MODE_ONCE
	render_target_clear_mode = ClearMode.CLEAR_MODE_NEVER
	

	#var uv = LevelUVPosition.get_uv_coords(col.get_position(), col.get_normal(), true)
	#if uv:
		#draw_viewport.paint(uv, color)
