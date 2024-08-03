class_name Charged extends Effect

func apply() -> void:
	super.apply()
	fighter.added_water_weakness = true
	fighter.damage_out_multiplier += 0.25

func remove() -> void:
	super.remove()
	fighter.added_water_weakness = false
	fighter.damage_out_multiplier -= 0.25
