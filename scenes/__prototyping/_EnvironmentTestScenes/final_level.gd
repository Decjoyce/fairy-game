extends daLevel

@export var tut_scene: daLevel
@export var stat_scene: StatueSection
@export var trap_scene: daLevel
@export var bb_scene: Node3D
@export var bb_easy_scene: Node3D
@export var bb_mid_scene: Node3D
@export var bb_hard_scene: Node3D
@export var bridge_scene: Node3D
@export var connector: Node3D
@export var connector2: Node3D
@export var saving_stone: SavingStone
@export var saving_stone_b: SavingStone

func setup_level_seq(seq: int) -> void:
	#super(seq)
	prints("dsokdjiopsjdiosjdoisjoid", seq)
	match seq:
		1:
			tut_scene.subscenes[2].visible = true
			tut_scene.subscenes[0].visible = false
			stat_scene.visible = true
		2:
			delete_tut()
			stat_scene.visible = true
		3:
			delete_tut()
			stat_scene.visible = true
			trap_scene.visible = true
		4:
			#delete_tut()
			trap_scene.visible = true
			trap_scene.subscenes[2].visible = true
			trap_scene.subscenes[0].visible = false
		5: 
			delete_tut()
			delete_trap()
			stat_scene.visible = true
		6:
			print("hmm")
			delete_scene(tut_scene)
			delete_scene(trap_scene)
			stat_scene.visible = true
			bb_scene.visible = true
		7:
			delete_tut()
			delete_trap()
			bb_scene.visible = true
			bb_mid_scene.visible = true
			#bb_easy_scene.visible = false
		8:
			delete_tut()
			delete_trap()
			bb_scene.visible = true
			bb_hard_scene.visible = true
			bb_easy_scene.visible = false
		9:
			delete_tut()
			delete_trap()
			delete_bb()
			bridge_scene.visible = true
			stat_scene.visible = true
		10:
			delete_tut()
			delete_trap()
			delete_bb()
			#delete_bridge()
			stat_scene.visible = true
		11:
			delete_tut()
			delete_trap()
			delete_bridge()
			delete_bb()
			disabled_saving_stones()
			delete_connector()
			stat_scene.visible = true
			stat_scene.statue_finished()
		_:
			printerr("what the hell brooooooooooo")

func delete_trap() -> void:
	printerr("WHY ")
	if trap_scene:
		trap_scene.queue_free()

func delete_bb() -> void:
	if bb_scene:
		bb_scene.queue_free()

func delete_tut() -> void:
	printerr("WHY ddsdsd")
	if tut_scene:
		tut_scene.queue_free()

func delete_bridge() -> void:
	if bridge_scene:
		bridge_scene.queue_free()

func delete_stat(sig: float = -1) -> void:
	if stat_scene:
		stat_scene.queue_free()

func delete_connector(sig: float = -1) -> void:
	connector.queue_free()
	connector2.queue_free()

func delete_scene(scn: Node3D) -> void:
	if scn:
		scn.queue_free()

func disabled_saving_stones() -> void:
	saving_stone.disable()
	saving_stone_b.disable()
