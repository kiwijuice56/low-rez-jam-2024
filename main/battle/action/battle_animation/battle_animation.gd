class_name BattleAnimation extends Node2D

@export var follows_target: bool = false

@export_enum("Background", "Foreground") var layer: String = "Foreground"

signal advanced

func animate() -> void:
	%AnimationPlayer.play(%AnimationPlayer.get_animation_list()[0])
	await advanced

func advance() -> void:
	advanced.emit()
