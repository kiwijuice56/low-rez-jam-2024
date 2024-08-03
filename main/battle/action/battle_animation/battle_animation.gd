class_name BattleAnimation extends Node2D

@export var follows_target: bool = false

@export_enum("Background", "Foreground") var layer: String = "Foreground"

signal advanced

func _ready() -> void:
	%AnimationPlayer.animation_finished.connect(_on_finished)

func _on_finished(_anim_name: String) -> void:
	queue_free()

func animate() -> void:
	%AnimationPlayer.play(%AnimationPlayer.get_animation_list()[1])
	await advanced

func advance() -> void:
	advanced.emit()
