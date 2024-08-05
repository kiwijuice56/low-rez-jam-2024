class_name FollowFloor extends Sprite2D

func _process(_delta: float) -> void:
	global_position.y = %SpriteHolder.get_parent().global_position.y
	global_position.x = %SpriteHolder.global_position.x
