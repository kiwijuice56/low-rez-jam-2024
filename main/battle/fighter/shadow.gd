class_name Shadow extends Sprite2D

@export var floor_y: float = 38

func _process(_delta: float) -> void:
	global_position.y = floor_y
	global_position.x = %SpriteHolder.global_position.x
