class_name Worm extends Sprite2D

func _ready() -> void:
	$AnimationPlayer.speed_scale = randf_range(0.8, 1.1)
