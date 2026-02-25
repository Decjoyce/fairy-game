extends Node3D
@export var lifetime : float = 50
@export var Debug : bool
@export var noiseThing : Node
var alert = preload("res://scenes/interactions/interactables/items/all_items/breakables/Noise_alert.tscn")
var instance = alert.instantiate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_visibility_changed() -> void:
	print("NoiseMadeForAI")
	add_child(instance)
##	add_child(noiseThing)
	await get_tree().create_timer(lifetime).timeout
	self.queue_free() 
	pass # Replace with function body.
