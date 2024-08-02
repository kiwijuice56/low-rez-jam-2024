class_name TipContainer extends PanelContainer

const TRANS_TIME: float = 0.06

func show_tip() -> void:
	get_parent().material.set_shader_parameter("fade", 1.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
	await tween.finished

func hide_tip() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished

func show_immediate() -> void:
	get_parent().material.set_shader_parameter("fade", 0.0)
	visible = true
