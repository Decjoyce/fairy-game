# Not ours - got from https://pastebin.com/SZYzgfju
## Via ~ How to make SPLATOON In Godot 4 ~ https://www.youtube.com/watch?v=4DFpLnEnKFk
### By ~ Crigz Vs Game Dev

extends MeshInstance3D
 
@export var draw_viewport: DrawViewport

func _ready():
	LevelUVPosition.set_mesh(self)
	(mesh.surface_get_material(0) as ShaderMaterial).set_shader_parameter("Paint", draw_viewport.get_texture())
