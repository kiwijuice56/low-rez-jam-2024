class_name LevelSubmenu extends Menu

const TRANS_TIME: float = 0.1

var mode: String = "level up"

var can_advance: bool = false
var ignore_change: bool = false
var fake_xp: int = 0:
	set(val):
		fake_xp = val
		Data.set_state("xp", fake_xp)
		if not ignore_change:
			%XPLabel.text = str(fake_xp)
var fake_xp_f: float = 0:
	set(val):
		fake_xp_f = val
		if not int(fake_xp_f) == fake_xp:
			fake_xp = int(fake_xp_f)
		%Bubble.material.set_shader_parameter("fV", fake_xp_f / Data.get_state("xp_goal"))

signal advanced

func _ready() -> void:
	visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if mode == "level up":
		if can_advance and event.is_action_pressed("accept", false):
			%AcceptPlayer.play()
			advanced.emit()
	if mode == "status":
		if event.is_action_pressed("cancel", false):
			%CancelPlayer.play()
			exit(false)
		if event.is_action_pressed("menu", false):
			%CancelPlayer.play()
			exit(true)

func display_level() -> void:
	if mode == "status":
		%TitleLabel.text = "level + xp"
	else:
		%TitleLabel.text = "you win!"
	
	%LevelLabel.text = str(Data.get_state("lvl"))
	%XPLabel.text = "%d" % Data.get_state("xp")
	%Bubble.material.set_shader_parameter("fV", float(Data.get_state("xp")) / Data.get_state("xp_goal"))

func level_up() -> void:
	Data.set_state("lvl", Data.get_state("lvl") + 1)
	
	%LevelLabel.text = str(Data.get_state("lvl"))
	%TitleLabel.text = "level up!"
	%AnimationPlayer.play("level_up")
	await %AnimationPlayer.animation_finished
	ignore_change = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "fake_xp_f", 0, 0.25)
	await tween.finished
	ignore_change = false
	
	Data.set_state("xp_goal", get_xp_goal(Data.get_state("lvl")))
	Data.set_state("xp", 0)
	fake_xp = 0
	fake_xp_f = 0

func get_xp_goal(level: int) -> int:
	return int(15 + pow(level / 99.0, 0.5) * 985)

func battle_end_sequence(xp_gained: int) -> int:
	var level_ups: int = 0
	fake_xp = Data.get_state("xp") 
	fake_xp_f = Data.get_state("xp") 
	while xp_gained > 0:
		var will_level_up: bool = false
		var sub_level_award: int = 0
		if Data.get_state("xp") + xp_gained >= Data.get_state("xp_goal"):
			will_level_up = true
			sub_level_award = Data.get_state("xp_goal") - Data.get_state("xp")
		else:
			sub_level_award = xp_gained
		%XPGainPlayer.play()
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "fake_xp_f", fake_xp_f + sub_level_award, sub_level_award / float(Data.get_state("xp_goal")))
		await tween.finished
		%XPGainPlayer.stop()
		
		xp_gained -= sub_level_award
		
		if will_level_up:
			level_ups += 1
			await level_up()
		else:
			break
	await get_tree().create_timer(1.0).timeout
	Data.set_state("xp", fake_xp)
	Data.set_state("xp_goal", get_xp_goal(Data.get_state("lvl")))
	
	%Flicker.flicker()
	can_advance = true
	await advanced
	%Flicker.stop()
	can_advance = false
	
	return level_ups

func enter() -> void:
	display_level()
	
	get_parent().material.set_shader_parameter("fade", 1.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
	await tween.finished
	
	set_process_input(true)
	entered.emit()

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	
	exited.emit(full_exit)
