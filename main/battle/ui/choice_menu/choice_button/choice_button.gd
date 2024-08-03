class_name ChoiceButton extends TextureRect

@export var normal: Texture
@export var hover: Texture
@export var disabled: Texture
@export var disabled_hover: Texture

@export var action_name: String
@export var cost_name: String
@export var cost_amount: String

@export var is_disabled: bool:
	set(val):
		is_disabled = val
		update_texture()

@export var is_hovered: bool:
	set(val):
		is_hovered = val
		update_texture()

@export var action: Action

@export var index: int

@export var description: String

func _ready() -> void:
	update_texture()

func initialize(new_action: Action, player_party: Array[Fighter], enemy_party: Array[Fighter], is_item: bool = false) -> void:
	action = new_action
	
	action_name = new_action.name
	
	if is_item:
		var count: int = Data.get_state("inventory/" + new_action.name.to_lower(), 0)
		cost_name = "count"
		cost_amount = " " + str(count)
		is_disabled = count <= 0 or len(action.get_available_targets(player_party, enemy_party)) == 0
	else:
		if action.tp_cost > 0:
			cost_name = "cost"
			cost_amount = " " + str(action.tp_cost)
		is_disabled = action.owner_fighter.tp < action.tp_cost or len(action.get_available_targets(player_party, enemy_party)) == 0
	
	%Icon.texture = action.icon
	
	update_texture()

func initialize_other(new_name: String, new_icon: Texture) -> void:
	action_name = new_name
	%Icon.texture = new_icon
	
	update_texture()

func update_texture() -> void:
	if is_disabled:
		texture = disabled_hover if is_hovered else disabled
	else:
		texture = hover if is_hovered else normal
