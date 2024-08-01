class_name Flicker extends TextureRect

func _ready() -> void:
	stop()

func flicker() -> void:
	%AnimationPlayer.play("flicker")
	modulate.a = 1

func stop() -> void:
	%AnimationPlayer.stop()
	modulate.a = 0
