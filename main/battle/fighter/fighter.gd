class_name Fighter extends Node2D

@export var stats: FighterStats
@export var innate_fire_weakness: bool = false
@export var innate_elec_weakness: bool = false 
@export var innate_water_weakness: bool = false

@export_group("Damage Widget")
@export var normal_damage_widget: PackedScene

var hp: int
var tp: int

var critical_multiplier: float
var accuracy_multiplier: float
var dodge_multiplier: float
var damage_out_multiplier: float
var damage_in_multiplier: float

var added_fire_weakness: bool = false
var added_water_weakness: bool = false
var added_elec_weakness: bool = false

func _ready() -> void:
	hp = stats.max_hp
	tp = stats.max_tp

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		hurt(randi_range(1, 16), false, false, false)

func hurt(damage: int, is_crit: bool, is_miss: bool, is_weak: bool) -> void:
	if is_miss:
		pass
	elif is_crit or is_weak:
		pass
	else:
		var new_widget: DamageWidget = normal_damage_widget.instantiate()
		new_widget.damage(damage)
		get_tree().get_root().add_child(new_widget)
		new_widget.global_position = %Center.global_position

func act(_data: Dictionary) -> Dictionary:
	return {"targets": [], "action": null}
