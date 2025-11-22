extends MarginContainer

@onready var console_line: LineEdit = %ConsoleLine
@onready var label_history_text: RichTextLabel = %History
@onready var label_auto_complete: RichTextLabel = %Autocomplete
@onready var label_current_selected: RichTextLabel = %CurrentSelected
@onready var label_alt_selected: RichTextLabel = %AltSelected

var history: Array[String] = []
var history_index: int = -1

var expression = Expression.new()

func _ready():
	console_line.text_submitted.connect(self._on_text_submitted)
	console_line.text_changed.connect(self._on_text_change)
	current_selected_object = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("_debug_objectpick"):
		select_object()
	if Input.is_action_just_pressed("_debug_objectpick_alt"):
		alt_select_object()
	
	if history.size() > 0:
		if Input.is_action_just_pressed("ui_page_up"):
			if history_index == -1:
				history_index = history.size() - 1
				console_line.text = history[history_index]
				return
			history_index = clampi(history_index - 1, 0, history.size() - 1)
			console_line.text = history[history_index]
		elif Input.is_action_just_pressed("ui_page_down"):
			history_index = clampi(history_index + 1, 0, history.size() -1)
			console_line.text = history[history_index]

# ↑ General Stuff ↑
# --------------------------------------------------------------------------------------------------
# ↓ Text Submitting Stuff ↓

@onready var autoco: RichTextLabel = $bg/Autocomplate
var autocomplete_methods: Array = []

func _on_text_change(command):
	if command == "":
		label_auto_complete.text = ""
		return
	
	if autocomplete_methods:
		var new_auto_complete: String = ""
		for method in autocomplete_methods:
			if method.begins_with(console_line.text):
				print(method.substr(console_line.text.length()))
				new_auto_complete = method
		if new_auto_complete != "":
			label_auto_complete.text = new_auto_complete
			return
		
	label_auto_complete.text = ""

func _on_text_submitted(command):
	history_index = -1
	var edited_command = command
	
	var error = expression.parse(edited_command, ["zarg"])
	if error != OK:
		print(expression.get_error_text())
		return
	var result 
	if alt_selected_object:
		result = expression.execute([alt_selected_object], current_selected_object, false)
	else:
		result = expression.execute([], current_selected_object, false)
	
	if not expression.has_execute_failed():
		if result != null:
			add_entry_to_history(edited_command + " : " + str(result) + "")
		else:
			add_entry_to_history(edited_command)
	else:
		add_entry_to_history(edited_command)
	
	update_history()
	console_line.clear()

func add_entry_to_history(entry) -> void:
	var entry_index: int = history.find(entry)
	if entry_index == -1:
		history.append(entry)
		return
	history.remove_at(entry_index)
	history.append(entry)

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
var alt_selected_object

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
		autocomplete_methods.clear()
		return
	if result.collider.is_in_group("debug_PickableObjects"):
		current_selected_object = result.collider
	elif result.collider.owner.is_in_group("debug_PickableObjects"):
		current_selected_object = result.collider.owner
	else: 
		current_selected_object = self
		update_select_text()
		autocomplete_methods.clear()
		return
	
	autocomplete_methods = current_selected_object.get_script().get_script_method_list().map(func (x): return x.name)
	update_select_text()

func update_select_text():
	if current_selected_object == self:
		label_current_selected.text = ""
		return
	label_current_selected.text = "[b]Selected: [color=aqua]" + current_selected_object.name

func alt_select_object() -> void:
	var space_state = node3dhelper.get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = Debug.cam.project_ray_origin(mousepos)
	var end = origin + Debug.cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if !result or !result.collider:
		alt_selected_object = null
		update_alt_select_text()
		return
	if result.collider.is_in_group("debug_PickableObjects"):
		alt_selected_object = result.collider
	elif result.collider.owner.is_in_group("debug_PickableObjects"):
		alt_selected_object = result.collider.owner
	else: 
		alt_selected_object = null
		update_alt_select_text()
		return
	update_alt_select_text()

func update_alt_select_text():
	if alt_selected_object == null:
		label_alt_selected.text = ""
		return
	label_alt_selected.text = "[b]Selected: [color=red]" + alt_selected_object.name
