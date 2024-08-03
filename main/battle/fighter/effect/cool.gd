class_name Cool extends Effect

func apply() -> void:
	super.apply()
	fighter.critical_multiplier += 2

func remove() -> void:
	super.remove()
	fighter.critical_multiplier -= 2
	
