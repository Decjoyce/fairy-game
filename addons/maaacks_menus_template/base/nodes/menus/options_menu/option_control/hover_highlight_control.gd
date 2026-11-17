extends Control


@onready var highlight: PanelContainer = $HighlightPanel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.hide()
	
	var row := get_parent()
	
	for node in row.find_children("*", "Control", true, false):
		if node == self or node == highlight:
			continue

		node.mouse_entered.connect(_update_highlight)
		node.mouse_exited.connect(_update_highlight)
		node.focus_entered.connect(_update_highlight)
		node.focus_exited.connect(_update_highlight)

func _update_highlight() -> void:
	var row := get_parent()
	var mouse_pos := get_global_mouse_position()
	
	for node in row.find_children("*", "Control", true, false):
		if node == self or node == highlight:
			continue
		
		if node.has_focus():
			highlight.show()
			return
		
		if node.get_global_rect().has_point(mouse_pos):
			highlight.show()
			return
	
	highlight.hide()
