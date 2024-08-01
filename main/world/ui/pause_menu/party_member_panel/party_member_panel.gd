class_name PartyMemberPanel extends MarginContainer

var fighter: Fighter

func initialize(new_fighter: Fighter) -> void:
	fighter = new_fighter
	%Icon.texture = fighter.get_node("%Sprite2D").texture
