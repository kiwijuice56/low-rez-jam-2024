class_name PlayerParty extends Node2D

const FIGHTER_PATH: String = "res://main/battle/fighter/"

func add_member(fighter_scene: PackedScene) -> void:
	add_child(fighter_scene.instantiate())
	Data.set_state("party_order", get_party_order_names())

func save_party_members() -> void:
	for child in get_children():
		ResourceSaver.save(child.stats, "user://%s.tres" % child.name)

func load_party_members() -> void:
	for fighter_name in Data.get_state("party_order"):
		var path: String = FIGHTER_PATH + "%s/%s.tscn" % [fighter_name, fighter_name]
		var new_fighter: Fighter = load(path).instantiate()
		add_child(new_fighter)
		if ResourceLoader.exists("user://%s.tres" % fighter_name):
			new_fighter.stats = ResourceLoader.load("user://%s.tres" % fighter_name)

func get_party_order_names() -> Array[String]:
	var names: Array[String] = []
	for child in get_children():
		names.append(child.name)
	return names
