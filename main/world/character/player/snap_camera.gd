class_name SnapCamera extends Camera2D

func _process(_delta: float) -> void:
	global_position = global_position.snapped(Vector2(1, 1))
