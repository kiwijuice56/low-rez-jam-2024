class_name Aura extends Effect

func apply() -> void:
	super.apply()
	fighter.accuracy_multiplier += 0.3
	fighter.dodge_multiplier += 0.3

func remove() -> void:
	super.remove()
	fighter.accuracy_multiplier -= 0.3
	fighter.dodge_multiplier -= 0.3
