class_name PartyMemberPanel extends MarginContainer

@export var hover_style: StyleBox
@export var normal_style: StyleBox

var fighter: Fighter

func initialize(new_fighter: Fighter) -> void:
	fighter = new_fighter
	%Icon.texture = fighter.get_node("%Sprite2D").texture

func hover() -> void:
	grab_focus()
	%BackgroundPanel.add_theme_stylebox_override("panel", hover_style)

func unhover() -> void:
	%BackgroundPanel.add_theme_stylebox_override("panel", normal_style)

func select() -> void:
	%HighlightSprite.visible = true

func deselect() -> void:
	%HighlightSprite.visible = false
