class_name DeathScene
extends Node3D

var prev_scene: String
@export var ui: Control
@export var ui_container: Control
@export var death_bg: Control
@export var reload_button: Button
@export var replay_button: Button
@export var exit_button: Button
@export var fade_anim: AnimationPlayer
var tween: Tween

@export var dmg_graphics: Array[Node3D]

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	EffectsPlayer.close_colorize()
	reload_button.grab_focus()

func disable_buttons() -> void:
	ui_container.visible = false
	reload_button.disabled = true
	replay_button.disabled = true
	exit_button.disabled = true

func load_last_save() -> void:
	disable_buttons()
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(ui, "modulate", Color.BLACK, 1)
	await tween.finished
	death_bg.modulate = Color.BLACK
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(ui, "modulate", Color.TRANSPARENT, 1)
	await tween.finished
	TEMPSaveGameHandler.load_game()
	queue_free()

func replay_level() -> void:
	disable_buttons()
	TEMPSaveGameHandler.load_scene_root(get_tree().current_scene.scene_file_path)
	queue_free()

func play_end() -> void:
	disable_buttons()
	SceneLoader.load_scene("res://scenes/_levels/menus/main_menu/Main_Menu_UI_NEW/MainMenuScene_NEW_UI.tscn")
	queue_free()

func set_graphics(dmg_type: int) -> void:
	dmg_graphics[dmg_type].visible = true
