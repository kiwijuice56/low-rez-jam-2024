class_name Charm extends Effect

func apply() -> void:
	super.apply()
	fighter.damage_out_multiplier -= 0.4

func remove() -> void:
	super.remove()
	fighter.damage_out_multiplier += 0.4
