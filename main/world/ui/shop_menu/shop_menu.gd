class_name ShopMenu extends Menu

func _ready() -> void:
	set_process_input(false)
	visible = false

func initialize(fighter: Fighter, action: Action) -> void:
	%SoulText.get_node("%Label").text = " " + str(Data.get_state("souls", 0))
	
	if action.get_index() in fighter.stats.unlocked_skills:
		%BoughtLabel.visible = true
		%PriceText.visible = false
	else:
		%BoughtLabel.visible = false
		%PriceText.get_node("%Label").texet = " " + str(action.soul_cost)
		%PriceText.visible = true
	
	%SkillNameLabel.text = action.name
	%FighterIcon.texture = fighter.get_node("%Sprite2D").texture
	%FighterNameLabel.text = fighter.name
	%Description.text = action.description
	
	%ChoiceButton.initialize_other(action.name, action.icon)
