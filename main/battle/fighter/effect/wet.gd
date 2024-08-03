class_name Wet extends Effect

func apply() -> void:
	super.apply()
	fighter.added_elec_weakness = true
	fighter.added_phys_resistance = true

func remove() -> void:
	super.remove()
	fighter.added_elec_weakness = false
	fighter.added_phys_resistance = false
