class_name Action extends Node2D

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
