@tool
extends PersistentObject

func on_save_game(sd: SavedData) -> void:
	super(sd)
	

func on_before_load_game() -> void:
	super()
	

func on_load_game(sd: SavedData) -> void:
	super(sd)
	
