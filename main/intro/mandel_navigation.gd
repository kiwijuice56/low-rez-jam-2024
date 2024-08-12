@tool
class_name MandelNavigation extends TextureRect

@export var camera: Camera3D 

func _process(_delta: float) -> void:
	material.set_shader_parameter("_cam_pos", camera.global_position)
	material.set_shader_parameter("_cam_mat", camera.global_transform.basis)
	material.set_shader_parameter("_screen_size", size)
