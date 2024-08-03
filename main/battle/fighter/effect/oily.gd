class_name Oily extends Effect

func apply() -> void:
	super.apply()
	fighter.added_fire_weakness = true
	fighter.dodge_multiplier += 0.25

func remove() -> void:
	super.remove()
	fighter.added_fire_weakness = false
	fighter.dodge_multiplier += 0.25
