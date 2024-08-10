class_name Eye extends Sprite2D

@export var radius: float

var target: Vector2

func _ready() -> void:
	%Timer.timeout.connect(_on_retime)
	%Timer.start(randf_range(0.4, .9))

func _on_retime() -> void:
	var angle: float = randf_range(0, 2 * PI)
	var real_radius: float = randf_range(0, radius)
	target = Vector2(real_radius, 0).rotated(angle)
	%Timer.start(randf_range(0.4, .9))

func _process(delta: float) -> void:
	position = lerp(position, target, delta * 6.0)
