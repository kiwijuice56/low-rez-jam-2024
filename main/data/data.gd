extends Node

var save_path: String = "user://"
var state: Dictionary

### functions called by title and main

func continue_game() -> void:
	load_state(0)
	Ref.player_party.load_party_members(false)

func new_game() -> void:
	initialize()
	Ref.player_party.load_party_members(true)

func game_exists() -> bool:
	return ResourceLoader.exists(save_path + "0_save.tres")

###

func initialize() -> void:
	set_state("room", "dead_room")
	set_state("anchor", "Default")
	
	set_state("souls", 0)
	set_state("lvl", 1)
	set_state("xp", 0)
	set_state("xp_goal", 15)
	set_state("kills", 0)
	
	set_state("party_order", ["ella"])
	
	set_state("inventory/tofu", 3)
	set_state("inventory/stirfry", 1)
	set_state("inventory/vitamin", 1)
	set_state("inventory/spider", 0)
	set_state("inventory/tnt", 0)

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
	Ref.player_party.save_party_members()
	
	var save_file: SaveFile = SaveFile.new()
	save_file.state = state
	save_file.version = int(ProjectSettings.get_setting("application/config/version"))
	
	ResourceSaver.save(save_file, save_path + str(file_id) + "_save.tres")

func load_state(file_id: int) -> void:
	var save_file: SaveFile = ResourceLoader.load(save_path + str(file_id) + "_save.tres")
	state = save_file.state
