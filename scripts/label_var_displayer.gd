extends Label3D

@export var node_to_examine: Node
@export var vars_to_display: Array[String]
@export var include_var_name: bool = true

func _ready() -> void:
	update_text()

func update_text(sig: float = -1) -> void:
	assert(node_to_examine, "Node not assigned to node_to_examine")
	text = ""
	var new_string: String = ""
	for i in vars_to_display.size():
		if vars_to_display[i] in node_to_examine:
			if include_var_name: new_string += vars_to_display[i] + " = "
			new_string += str(node_to_examine.get(vars_to_display[i])) + "\n"
	text = new_string
