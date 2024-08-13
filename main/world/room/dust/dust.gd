class_name Dust extends CPUParticles2D

func _ready() -> void:
	await get_parent().ready
	if has_node("%Button"):
		%Button.pressed.connect(_on_pressed)
		if Data.get_state(%Button.key, false):
			_on_pressed()

func _on_pressed():
	emitting = false
