class_name Shadow extends Sprite2D

const FLOOR_Y: float = 38

func _process(_delta: float) -> void:
	global_position.y = FLOOR_Y
	global_position.x = %SpriteHolder.global_position.x
