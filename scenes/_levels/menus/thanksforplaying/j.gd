extends Control

@export var ap: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Button.grab_focus()

func return_to_menu() -> void:
	$Button.disabled = true
	ap.play("fade_out")
	await ap.animation_finished
	get_tree().change_scene_to_file("res://scenes/_levels/menus/main_menu/Main_Menu_UI_NEW/MainMenuScene_NEW_UI.tscn")
