class_name Fighter extends Node2D

@export var stats: FighterStats
@export var innate_fire_weakness: bool = false
@export var innate_elec_weakness: bool = false 
@export var innate_water_weakness: bool = false

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
		if hp == 0:
			dead = true
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

func battle_reset() -> void:
	for effect in %Effects.get_children():
		effect.fighter = self
		effect.remove()
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

func after_turn() -> void:
	for effect in %Effects.get_children():
		if effect.active:
			await effect.after_turn()

func apply_effect(effect_name: String, duration: int ) -> void:
	%Effect.get_node(effect_name).reset_timer(duration)
	%Effect.get_node(effect_name).apply()

# changing HP
func hurt(damage: int, is_crit: bool, is_miss: bool, is_weak: bool) -> void:
	var widget: DamageWidget
	var text: String
	
	%AnimationPlayer.stop()
	%SpriteHolder.position = Vector2()
	%Sprite2D.material.set_shader_parameter("flash", Color.BLACK)
	
	if is_miss:
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
	else:
		%AnimationPlayer.play("hurt" if hp - damage > 0 else "death")
		widget = normal_damage_widget.instantiate()
		text = " " + str(damage)
	
	hp -= damage
	
	widget.damage(text)
	
	get_parent().get_parent().add_child(widget)
	widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

# changing TP
func change_tp(damage: int) -> void:
	tp -= damage
	
	var widget: DamageWidget = tp_damage_widget.instantiate()
	if damage <= 0:
		widget.damage(" +" + str(abs(damage)))
	else:
		widget.damage(" " + str(damage))
	
	get_parent().get_parent().add_child(widget)
	widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

func update_ui() -> void:
	%HPColoredText.get_node("Label").text = " " + str(hp)
	%TPColoredText.get_node("Label").text = " " + str(tp)

func get_choice(_own_party: Array[Fighter], other_party: Array[Fighter]) -> Dictionary:
	var targets: Array[Fighter] = [other_party.pick_random()]
	return {"targets": targets, "action": base_attack}
