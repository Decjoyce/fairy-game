extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is not PlayerTest: return
	var player = area.get_parent()
	var interact = player.get_node("Interaction")
	interact.enable_crouch_promt()
	
	
	#print("entered",player, interact)
	
		
	pass # Replace with function body.


func _on_area_exited(area: Area3D) -> void:
	if area.get_parent() is not PlayerTest: return
	var player = area.get_parent()
	var interact = player.get_node("Interaction")
	interact.disable_crouch_promt()
	
	pass # Replace with function body.
	
