class_name FollowLighht extends PointLight2D

func _process(_delta: float) -> void:
	global_position = Ref.player.global_position
