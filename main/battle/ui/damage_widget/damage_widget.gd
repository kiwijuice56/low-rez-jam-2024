class_name DamageWidget extends Node2D

@export var speed_min: float = 0.0
@export var speed_max: float = 8.0

var speed: float

func damage(amount: int) -> void:
	speed = randf_range(speed_min, speed_max) * (-1 if randf() < 0.5 else 1)
	%DamageLabel.text = str(amount)
	%AnimationPlayer.play("bounce")
	await %AnimationPlayer.animation_finished
	queue_free()

func _process(delta: float) -> void:
	position.x += delta * speed
