# Not ours - got from https://pastebin.com/YJns6a2T
## Via ~ How to make SPLATOON In Godot 4 ~ https://www.youtube.com/watch?v=4DFpLnEnKFk
### By ~ Crigz Vs Game Dev

extends Node2D
 
@export var texture: Texture2D
@export var brush_size: float = 100
 
#@onready var calc = $'../../ScoreCalculator'
 
var brush_queue = []
 
func queue_brush(ne_position: Vector2, colour: Color):
	brush_queue.push_back([position, colour])
	queue_redraw()
	#print("maint")
 
func _draw():
	for b in brush_queue:
		#draw_texture_rect(texture, Rect2(b[0].x - brush_size/2, b[0].y - brush_size/2, brush_size, brush_size), false, Color.AQUA)
		draw_circle(Vector2(b[0].x - brush_size/2, b[0].y - brush_size/2), brush_size, Color.AQUA)
	brush_queue = []
	
	#calc.recalculate_score()
