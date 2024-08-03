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

var hp: int:
	set(val):
		hp = val
		update_ui()
var tp: int:
	set(val):
		tp = val
		update_ui()

var critical_multiplier: float
var accuracy_multiplier: float
var dodge_multiplier: float
var damage_out_multiplier: float
var damage_in_multiplier: float

var added_fire_weakness: bool = false
var added_water_weakness: bool = false
var added_elec_weakness: bool = false

var dead: bool = false

func _ready() -> void:
	hp = stats.max_hp
	tp = stats.max_tp
	%Sprite2D.material = %Sprite2D.material.duplicate()

func _input(event: InputEvent) -> void:
	if %PointInfo.visible:
		return
	if event.is_action_pressed("cancel", false):
		hurt(randi_range(1, 16), randf() < 0.24, randf() < 0.15, false)

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
		%AnimationPlayer.play("hurt")
		widget = critical_damage_widget.instantiate()
		text = " " + str(damage)
	else:
		%AnimationPlayer.play("hurt")
		widget = normal_damage_widget.instantiate()
		text = " " + str(damage)
	
	widget.damage(text)
	# I know, this is terrible...
	get_parent().get_parent().add_child(widget)
	widget.global_position = %Center.global_position - Vector2(widget.get_node("%DamageLabel").size.x / 2, 0)

func update_ui() -> void:
	%HPColoredText.get_node("Label").text = " " + str(hp)
	%TPColoredText.get_node("Label").text = " " + str(tp)

func get_choice(_own_party: Array[Fighter], _other_party: Array[Fighter]) -> Dictionary:
	return {"targets": [], "action": null}
