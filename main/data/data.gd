extends Node

var save_path: String = "res://main/data/debug_files/"
var state: Dictionary

func save_state(file_id: int) -> void:
	var save_file: SaveFile = SaveFile.new()
	save_file.state = state
	save_file.version = int(ProjectSettings.get_setting("application/config/version"))
	
	ResourceSaver.save(save_file, save_path + str(file_id) + "_save.tres")

func load_state(file_id: int) -> void:
	var save_file: SaveFile = ResourceLoader.load(save_path + str(file_id) + "_save.tres")
	state = save_file.state
