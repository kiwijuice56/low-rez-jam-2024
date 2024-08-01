extends Node

var save_path: String = "res://main/data/debug_files/"
var state: Dictionary

func initialize() -> void:
	pass

func set_state(property_path: String, val: Variant) -> void:
	var node: Dictionary = state
	var levels: PackedStringArray = property_path.split("/")
	for i in range(len(levels) - 1):
		if not levels[i] in node:
			node[levels[i]] = {} 
		node = node[levels[i]]
	node[levels[-1]] = val

func get_state(property_path: String, default: Variant = null) -> Variant:
	var node: Dictionary = state
	var levels: PackedStringArray = property_path.split("/")
	for i in range(len(levels) - 1):
		if not levels[i] in node:
			return default
		node = node[levels[i]]
	return node[levels[-1]] if levels[-1] in node else default

func save_state(file_id: int) -> void:
	var save_file: SaveFile = SaveFile.new()
	save_file.state = state
	save_file.version = int(ProjectSettings.get_setting("application/config/version"))
	
	ResourceSaver.save(save_file, save_path + str(file_id) + "_save.tres")

func load_state(file_id: int) -> void:
	var save_file: SaveFile = ResourceLoader.load(save_path + str(file_id) + "_save.tres")
	state = save_file.state
