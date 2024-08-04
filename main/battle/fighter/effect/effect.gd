class_name Effect extends Node2D

@export var length_multiplier: float = 1.0

var active: bool = false
var timer: int 
var fighter: Fighter

func after_turn() -> void:
	timer -= 1
	if timer <= 0 and active:
		remove()

func reset_timer(new_time: int) -> void:
	timer = new_time

func apply() -> void:
	assert(not active)
	active = true
	visible = true

func remove() -> void:
	assert(active)
	active = false
	visible = false
