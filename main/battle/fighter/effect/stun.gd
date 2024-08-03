class_name Stun extends Effect

@export var gradient: GradientTexture1D
@export var rotation_speed: float = 6.0
@export var jump_speed: float = 4.0

@export var radius: Vector2 = Vector2(14, 6)
@export var height: float = 3.0

var angle: float
var height_angle: float

func _process(delta: float) -> void:
	var angle_offset: float = 2 * PI / get_child_count()
	angle += delta * rotation_speed
	height_angle += delta * jump_speed
	for i in range(get_child_count()):
		var child: Node2D = get_child(i)
		child.position.x = cos(angle + angle_offset * i) * radius.x
		child.position.y = sin(angle + angle_offset * i) * radius.y
		child.z_index = sign(child.position.y) 
		child.position.y += sin(height_angle + angle_offset * i) * height
		child.modulate = gradient.gradient.sample(((child.position.y / radius.y) + 1.0) * 0.7 + 0.3)
