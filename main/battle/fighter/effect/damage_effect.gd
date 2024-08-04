class_name DamageEffect extends Effect

@export var action: Action

func after_turn() -> void:
	var targets: Array[Fighter] = [fighter]
	await get_tree().create_timer(0.2).timeout
	await action.act(fighter, targets)
	super.after_turn()
