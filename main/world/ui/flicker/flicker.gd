class_name Flicker extends TextureRect

func _ready() -> void:
	stop()

func flicker() -> void:
	%AnimationPlayer.play("flicker")
	%AnimationPlayer.seek(0.4)

func stop() -> void:
	%AnimationPlayer.stop()
	modulate.a = 0
