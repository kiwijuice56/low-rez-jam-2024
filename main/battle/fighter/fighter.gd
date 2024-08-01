class_name Fighter extends Node2D

@export var stats: FighterStats
@export var innate_fire_weakness: bool = false
@export var innate_elec_weakness: bool = false 
@export var innate_water_weakness: bool = false

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

func act(_data: Dictionary) -> Dictionary:
	return {"targets": [], "action": null}
