# Not ours - got from https://pastebin.com/AQm9adaq
## Via ~ How to make SPLATOON In Godot 4 ~ https://www.youtube.com/watch?v=4DFpLnEnKFk
### By ~ Crigz Vs Game Dev
class_name DrawViewport
extends SubViewport
 
@onready var brush: Node2D = $Brush
 
func paint(position : Vector2, colour: Color = Color(1, 1, 1)):
	#print("taint")
	brush.queue_brush(position * 1024, colour)

	
