class_name GameOver extends CanvasLayer

func _ready() -> void:
	visible = false

func game_over() -> void:
	visible = true
	%AnimationPlayer.play("game_over")
	await %AnimationPlayer.animation_finished
	await Ref.transition.trans_in()
	visible = false
