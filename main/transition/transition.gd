class_name Transition extends CanvasLayer

func _ready() -> void:
	visible = true
	$BlockyFade.material.set_shader_parameter("fade", 0.0)

func trans_in() -> void:
	%AnimationPlayer.play("trans_in")
	await %AnimationPlayer.animation_finished

func trans_out() -> void:
	%AnimationPlayer.play("trans_out")
	await %AnimationPlayer.animation_finished

func battle_trans_in() -> void:
	Ref.player.get_node("%CameraAnimationPlayer").play("trans_in")
	%AnimationPlayer.play("trans_in")
	await %AnimationPlayer.animation_finished
	Ref.player.get_node("%CameraAnimationPlayer").play("RESET")
