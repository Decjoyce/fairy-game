@tool
extends PersistentObject

func on_save_game(saved_data: Array[SavedData]) -> void:
	super(saved_data)
	

func on_before_load_game() -> void:
	super()
	

func on_load_game(saved_data: SavedData) -> void:
	super(saved_data)
	
