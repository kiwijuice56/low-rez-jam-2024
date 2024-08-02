class_name PlayerParty extends Node2D

const FIGHTER_PATH: String = "res://main/battle/fighter/"

func add_member(fighter_scene: PackedScene) -> void:
	add_child(fighter_scene.instantiate())
	Data.set_state("party_order", get_party_order_names())

func save_party_members() -> void:
	for child in get_children():
		ResourceSaver.save(child.stats, "user://%s.tres" % child.name.to_lower())

func load_party_members() -> void:
	for fighter_name in Data.get_state("party_order"):
		var path: String = FIGHTER_PATH + "%s/%s.tscn" % [fighter_name, fighter_name]
		var new_fighter: Fighter = load(path).instantiate()
		add_child(new_fighter)
		if ResourceLoader.exists("user://%s.tres" % fighter_name.to_lower()):
			new_fighter.stats = ResourceLoader.load("user://%s.tres" % fighter_name.to_lower())

func get_party_order_names() -> Array[String]:
	var names: Array[String] = []
	for child in get_children():
		names.append(child.name.to_lower())
	return names

func swap(i1: int, i2: int) -> void:
	var fighter1: Fighter = get_child(i1)
	var fighter2: Fighter = get_child(i2)
	remove_child(fighter1)
	remove_child(fighter2)
	if i1 < i2:
		add_child(fighter2, i1)
		add_child(fighter1, i2)
	else:
		add_child(fighter1, i2)
		add_child(fighter2, i1)

func get_active_fighters() -> Array[Fighter]:
	var fighters: Array[Fighter] = []
	for i in range(min(3, get_child_count())):
		fighters.append(get_child(i))
	return fighters
