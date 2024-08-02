class_name Fighter extends Node2D

@export var stats: FighterStats
@export var innate_fire_weakness: bool = false
@export var innate_elec_weakness: bool = false 
@export var innate_water_weakness: bool = false

@export_group("Damage Widget")
@export var normal_damage_widget: PackedScene
@export var critical_damage_widget: PackedScene
@export var miss_damage_widget: PackedScene

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
		hurt(randi_range(1, 16), randf() < 0.24, randf() < 0.24, false)

func hurt(damage: int, is_crit: bool, is_miss: bool, is_weak: bool) -> void:
	var widget: DamageWidget
	var text: String
	
	if is_miss:
		widget = miss_damage_widget.instantiate()
		text = " miss"
	elif is_crit or is_weak:
		widget = critical_damage_widget.instantiate()
		text = " " + str(damage)
	else:
		widget = normal_damage_widget.instantiate()
		text = " " + str(damage)
	
	widget.damage(text)
	get_tree().get_root().add_child(widget)
	widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

func act(_data: Dictionary) -> Dictionary:
	return {"targets": [], "action": null}
