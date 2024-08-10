class_name Cool extends Effect

func apply() -> void:
	super.apply()
	fighter.critical_multiplier += 3

func remove() -> void:
	super.remove()
	fighter.critical_multiplier -= 3
	
