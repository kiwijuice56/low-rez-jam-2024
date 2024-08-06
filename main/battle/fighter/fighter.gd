class_name Fighter extends Node2D

@export var stats: FighterStats
@export var innate_fire_weakness: bool = false
@export var innate_elec_weakness: bool = false 
@export var innate_water_weakness: bool = false

@export_group("Level")
@export var strength_grow: int = 1
@export var magic_grow: int = 1
@export var defence_grow: int = 1
@export var luck_grow: int = 1
@export var max_hp_grow: int = 2
@export var max_tp_grow: int = 2

@export_group("Action")
@export var base_attack: Action
@export var base_pass: Action

@export_group("Damage Widget")
@export var normal_damage_widget: PackedScene
@export var critical_damage_widget: PackedScene
@export var miss_damage_widget: PackedScene
@export var heal_damage_widget: PackedScene
@export var tp_damage_widget: PackedScene

var hp: int:
	set(val):
		hp = val
		hp = clamp(hp, 0, stats.max_hp)
		if hp <= 0:
			kill()
		update_ui()
var tp: int:
	set(val):
		tp = val
		tp = clamp(tp, 0, stats.max_tp)
		update_ui()

var critical_multiplier: float
var accuracy_multiplier: float
var dodge_multiplier: float
var damage_out_multiplier: float
var damage_in_multiplier: float

var added_fire_weakness: bool = false
var added_water_weakness: bool = false
var added_elec_weakness: bool = false
var added_phys_resistance: bool = false

var dead: bool = false

func _ready() -> void:
	visible = false
	%Sprite2D.material = %Sprite2D.material.duplicate()
	%Sprite2D.material.set_shader_parameter("h_frames", %Sprite2D.hframes)
	%Effects.global_position = %Center.global_position

func cure_all_effects() -> void:
	for effect in %Effects.get_children():
		effect.fighter = self
		if effect.active:
			effect.remove()

func battle_reset() -> void:
	cure_all_effects()
	hp = stats.max_hp
	tp = stats.max_tp
	critical_multiplier = 1.0
	accuracy_multiplier = 1.0
	dodge_multiplier = 1.0
	damage_in_multiplier = 1.0
	damage_out_multiplier = 1.0
	added_fire_weakness = false
	added_water_weakness = false
	added_elec_weakness = false
	added_phys_resistance = false

func kill() -> void:
	dead = true
	cure_all_effects()

func revive() -> void:
	hp = stats.max_hp
	dead = false
	update_ui()

func start_turn() -> void:
	%AnimationPlayer.play("start")

func after_turn() -> void:
	for effect in %Effects.get_children():
		if effect.active:
			await effect.after_turn()

# changing HP
func hurt(damage: int, is_crit: bool, is_miss: bool, is_weak: bool, is_revival: bool = false) -> void:
	var widget: DamageWidget
	var text: String
	
	if dead and not is_revival:
		return
	
	%AnimationPlayer.stop(true)
	%SpriteHolder.position = Vector2()
	%Sprite2D.material.set_shader_parameter("flash", Color.BLACK)
	
	if is_revival:
		revive()
		%AnimationPlayer.play("revive")
		return
	elif is_miss:
		%AnimationPlayer.play("miss")
		widget = miss_damage_widget.instantiate()
		text = " miss"
	elif is_crit or is_weak:
		%AnimationPlayer.play("hurt" if hp - damage > 0 else "death")
		widget = critical_damage_widget.instantiate()
		text = " " + str(damage)
	elif damage < 0:
		%AnimationPlayer.play("heal")
		widget = heal_damage_widget.instantiate()
		text = " +" + str(abs(damage))
	elif damage > 0:
		%AnimationPlayer.play("hurt" if hp - damage > 0 else "death")
		widget = normal_damage_widget.instantiate()
		text = " " + str(damage)
	
	hp -= damage
	
	if not damage == 0 or is_miss:
		widget.damage(text)
		get_parent().get_parent().add_child(widget)
		widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

# changing TP
func change_tp(damage: int) -> void:
	if dead:
		return
	
	tp -= damage
	
	if not damage == 0:
		var widget: DamageWidget = tp_damage_widget.instantiate()
		if damage < 0:
			widget.damage(" +" + str(abs(damage)))
		else:
			widget.damage(" " + str(damage))
		
		
		get_parent().get_parent().add_child(widget)
		widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

func update_ui() -> void:
	%HPColoredText.get_node("Label").text = " " + str(hp)
	%TPColoredText.get_node("Label").text = " " + str(tp)

# pick random
func get_choice(own_party: Array[Fighter], other_party: Array[Fighter]) -> Dictionary:
	var all_actions: Array[Action] = []
	all_actions.append(base_attack)
	for action in %Skills.get_children():
		all_actions.append(action)
	
	var possible_actions: Array[Action] = []
	for action in all_actions:
		if len(action.get_available_targets(own_party, other_party)) > 0:
			possible_actions.append(action)
	
	var action: Action = possible_actions.pick_random()
	var targets: Array[Fighter] = []
	
	match action.target_amount:
		"Single": 
			targets.append(action.get_available_targets(own_party, other_party).pick_random())
		_:
			targets = action.get_available_targets(own_party, other_party)
	
	return {"targets": targets, "action": action}
