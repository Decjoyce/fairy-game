extends Node

@export var linked_nodes: Array[Node3D]

func enable_obj(sig: float) -> void:
	for n in linked_nodes:
		n.visible = true

func disable_obj(sig: float) -> void:
	for n in linked_nodes:
		n.visible = false

func toggle_visibilty(sig: float) -> void:
	var on_or_off: bool = sig >= 0.5
	for n in linked_nodes:
		n.visible = on_or_off

func swap_visibilty(sig: float) -> void:
	for n in linked_nodes:
		n.visible = !n.visible

func enable_one(node_index: int) -> void:
	assert(node_index < 0 or node_index >= linked_nodes.size(), "number passed in was less/more than linked_nodes' size")
	for i in linked_nodes.size():
		if i == node_index: linked_nodes[i].visible = true
		else: linked_nodes[i].visible = false

func enable_all_but_one(node_index: int) -> void:
	assert(node_index < 0 or node_index >= linked_nodes.size(), "number passed in was less/more than linked_nodes' size")
	for i in linked_nodes.size():
		if i == node_index: linked_nodes[i].visible = false
		else: linked_nodes[i].visible = true

#func enable_some(node_index: Array) -> void:
	#for i in linked_nodes.size():
		#if i == node_index: linked_nodes[i].visible = true
		#else: linked_nodes[i].visible = false

#func enable_all_but_some(node_index: int) -> void:
	#assert(node_index < 0 or node_index >= linked_nodes.size(), "number passed in was less/more than linked_nodes' size")
	#for i in linked_nodes.size():
		#if i == node_index: linked_nodes[i].visible = false
		#else: linked_nodes[i].visible = true
