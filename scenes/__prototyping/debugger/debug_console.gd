extends MarginContainer

@onready var console_line: LineEdit = %ConsoleLine
@onready var label_history_text: RichTextLabel = %History
@onready var label_auto_complete: RichTextLabel = %Autocomplete
@onready var label_current_selected: RichTextLabel = %CurrentSelected

var history: Array[String] = []
var history_index: int = -1

var expression = Expression.new()

func _ready():
	console_line.text_submitted.connect(self._on_text_submitted)
	current_selected_object = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("_debug_objectpick"):
		select_object()
	
	label_auto_complete.text = console_line.text + "[i].doncheadle[/i]"

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Text Submitting Stuff ↓

var pre_text: String

func _on_text_submitted(command):
	var error = expression.parse(command)
	if error != OK:
		print(expression.get_error_text())
		return
	var result = expression.execute([], current_selected_object, false)
	if not expression.has_execute_failed():
		if result != null:
			history.append(command + " : [b][color=green]" + str(result) + "[/color][/b]")
		else:
			history.append(command)
	else:
		history.append(command)
	
	update_history()
	console_line.clear()

func update_history() -> void:
	var _updatated_entries: String = ""
	for _prev_entries in history:
		_updatated_entries += _prev_entries + "\n"
	label_history_text.text = _updatated_entries

# ↑ Text Submitting Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Object Selecting Stuff ↓

@onready var node3dhelper: Node3D = $node3dhelper
var current_selected_object

func select_object() -> void:
	var space_state = node3dhelper.get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = Debug.cam.project_ray_origin(mousepos)
	var end = origin + Debug.cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider:
		current_selected_object = self
		update_select_text()
		return
	if result.collider.is_in_group("debug_PickableObjects"):
		current_selected_object = result.collider
	elif result.collider.owner.is_in_group("debug_PickableObjects"):
		current_selected_object = result.collider.owner
	else: 
		current_selected_object = self
		update_select_text()
		return
	update_select_text()

func update_select_text():
	if current_selected_object == self:
		label_current_selected.text = ""
		return
	label_current_selected.text = "[b]Selected: [color=aqua]" + current_selected_object.name
