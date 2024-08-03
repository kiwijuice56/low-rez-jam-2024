class_name Action extends Node2D

@export var icon: Texture
@export var tp_cost: int
@export var power: float
@export var accuracy: float = 1.0
@export var critical: float = 0.0
@export_enum("Other", "Own", "All") var target_group: String = "Other"
@export_enum("Single", "All", "Random") var target_amount: String = "Single"
@export var hit_amount_min: int = 1
@export var hit_amount_max: int = 13
@export_group("Status Effect")
@export var status_chance: float = 1.0
@export_flags("Poison", "Ablaze", "Bless", "Charm", "Broken", "Cool", "Aura", "Oily", "Wet", "Charged", "Stun") var status_effects: int

var owner_fighter: Fighter

func _ready() -> void:
	owner_fighter = owner

# action-specific stuff... ex: healing should not target fully healed fighters
func can_target(_target: Fighter) -> bool:
	return true 

func get_available_targets(own_party: Array[Fighter], other_party: Array[Fighter]) -> Array[Fighter]:
	var targets: Array[Fighter] = []
	var pool: Array[Fighter] = []
	match target_group:
		"All":
			pool = own_party + other_party
		"Own":
			pool = own_party
		"Other":
			pool = other_party
	for possible_target in pool:
		if can_target(possible_target):
			targets.append(possible_target)
	return targets
