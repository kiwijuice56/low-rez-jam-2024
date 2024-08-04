class_name Pass extends Action

func act(user: Fighter, _targets: Array[Fighter]) -> TurnUsage:
	Ref.battle_text.display_text(use_text % user.name, Ref.battle.TEXT_SPEED)
	await get_tree().create_timer(DELAY).timeout
	return TurnUsage.ADVANTAGE
