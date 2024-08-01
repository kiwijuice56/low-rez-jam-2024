class_name Fighter extends Node2D

@export var stats: FighterStats

var hp: int
var tp: int

func _ready() -> void:
	hp = stats.max_hp
	tp = stats.max_tp
