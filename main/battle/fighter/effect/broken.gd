class_name Broken extends Effect

func apply() -> void:
	super.apply()
	fighter.damage_in_multiplier += 0.7
	%Sprite2D.material.set_shader_parameter("broken", true)

func remove() -> void:
	super.remove()
	fighter.damage_in_multiplier -= 0.7
	%Sprite2D.material.set_shader_parameter("broken", false)
