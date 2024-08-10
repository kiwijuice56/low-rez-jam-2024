class_name Dust extends CPUParticles2D

func _ready() -> void:
	await get_parent().ready
	%Button.pressed.connect(_on_pressed)
	if Data.get_state(%Button.key, false):
		_on_pressed()

func _on_pressed():
	emitting = false
