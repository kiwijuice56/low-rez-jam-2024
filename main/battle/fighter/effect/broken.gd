class_name Broken extends Effect

func apply() -> void:
	super.apply()
	fighter.damage_in_multiplier += 0.5

func remove() -> void:
	super.remove()
	fighter.damage_in_multiplier -= 0.5
