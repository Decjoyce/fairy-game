extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Button.grab_focus()

func return_to_menu() -> void:
	SceneLoader.load_scene("res://scenes/_levels/menus/main_menu/Main_Menu_UI_NEW/MainMenuScene_NEW_UI.tscn")
