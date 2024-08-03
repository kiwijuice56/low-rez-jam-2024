class_name Action extends Node2D

const DELAY: float = 0.4

@export var icon: Texture
@export_multiline var description: String
@export var use_text: String = "%s"
@export var verb: String = "attack"
@export var tp_cost: int
@export var power: float
@export var accuracy: float = 1.0
@export var critical: float = 0.0
@export var piece: bool = false
@export var constant_damage: int = 0
@export_enum("magic", "strength") var attack_stat: String = "strength" 
@export_enum("Other", "Own", "All") var target_group: String = "Other"
@export_enum("Single", "All", "Random") var target_amount: String = "Single"
@export var hit_amount_min: int = 1
@export var hit_amount_max: int = 13
@export_group("Status Effect")
@export var status_chance: float = 1.0
@export_flags("Poison", "Ablaze", "Bless", "Charm", "Broken", "Cool", "Aura", "Oily", "Wet", "Charged", "Stun") var status_effects: int
@export_group("Element")
@export var is_phys: bool = false
@export var is_fire: bool = false
@export var is_elec: bool = false
@export var is_water: bool = false
@export_group("Animation")
@export var animations: Array[PackedScene]
@export var per_target_delay: float = 0.1
@export_group("Item")
@export var is_item: bool
@export var revival: bool

var owner_fighter: Fighter
var current_use: TurnUsage

enum TurnUsage { NORMAL, WASTE, ADVANTAGE }

func _ready() -> void:
	if not is_item:
		owner_fighter = owner

func hit_calculation(user: Fighter, target: Fighter) -> Dictionary:
	var data: Dictionary = {}
	
	if constant_damage == 0:
		data.damage = randf_range(0.8, 1.1) *  (Data.get_state("lvl") + (power + user.stats.get(attack_stat)))
		if not piece:
			data.damage *= 24.0 / (24.0 + user.stats.defence)
	else:
		data.damage = constant_damage
	
	data.damage *= user.damage_out_multiplier * target.damage_in_multiplier
	
	if is_fire and (target.added_fire_weakness or target.innate_fire_weakness):
		data.weak = true
		data.damage *= 2 
	if is_water and (target.added_water_weakness or target.innate_water_weakness):
		data.weak = true
		data.damage *= 2
	if is_elec and (target.added_elec_weakness or target.innate_elec_weakness):
		data.weak = true
		data.damage *= 2 
	if is_phys and target.added_phys_resistance:
		data.damage *= 0.5
	
	if randf() < critical * user.critical_multiplier:
		data.crit = true
		data.damage *= 2
	
	if randf() > accuracy / target.dodge_multiplier * user.accuracy_multiplier:
		data.miss = true
		data.damage = 0
	
	return data

func per_target_act(user: Fighter, target: Fighter, animation: BattleAnimation) -> void:
	var new_animation: BattleAnimation = animation.duplicate()
	if new_animation.layer == "Foreground":
		Ref.battle_animation_foreground.add_child(new_animation)
	else:
		Ref.battle_animation_background.add_child(new_animation)
	new_animation.global_position = target.get_node("%Center").global_position
	await new_animation.animate()
	
	var data: Dictionary = hit_calculation(user, target)
	print(data)
	target.hurt(data.damage, "crit" in data, "miss" in data, "weak" in data)
	
	
	if "miss" in data:
		current_use = TurnUsage.WASTE
	if ("crit" in data or "weak" in data) and not current_use == TurnUsage.WASTE:
		current_use = TurnUsage.ADVANTAGE

func act(user: Fighter, targets: Array[Fighter]) -> TurnUsage:
	current_use = TurnUsage.NORMAL
	if is_item:
		Data.set_state("inventory/" + name, Data.get_state("inventory/" + name, 0) - 1)
	else:
		user.tp -= tp_cost
	
	Ref.battle_text.display_text(use_text % user.name, Ref.battle.TEXT_SPEED)
	await get_tree().create_timer(DELAY).timeout
	
	for animation_scene in animations:
		var animation: BattleAnimation = animation_scene.instantiate()
		
		# the "finisher" animation must always be a follow_target type
		if animation.follows_target:
			for _hit in range(randi_range(hit_amount_min, hit_amount_max)):
				var actual_targets: Array[Fighter] = []
				
				if target_amount == "Random":
					actual_targets.append(targets.pick_random())
				else:
					actual_targets = targets
				
				for i in range(len(actual_targets) - 1):
					per_target_act(user, actual_targets[i], animation)
					await get_tree().create_timer(per_target_delay).timeout
				await per_target_act(user, actual_targets[len(actual_targets) - 1], animation)
				await get_tree().create_timer(per_target_delay).timeout
		else: # screen animations
			if animation.layer == "Foreground":
				Ref.battle_animation_foreground.add_child(animation)
			else:
				Ref.battle_animation_background.add_child(animation)	
			await animation.animate()
	
	return current_use

# action-specific stuff... ex: healing should not target fully healed fighters
func can_target(_target: Fighter) -> bool:
	return true 

func get_available_targets(own_party: Array[Fighter], other_party: Array[Fighter]) -> Array[Fighter]:
	var targets: Array[Fighter] = []
	var pool: Array[Fighter] = []
	match target_group:
		"All":
			pool = own_party + other_party
		"Own":
			pool = own_party
		"Other":
			pool = other_party
	for possible_target in pool:
		if can_target(possible_target):
			targets.append(possible_target)
	return targets
