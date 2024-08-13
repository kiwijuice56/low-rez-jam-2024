class_name StatusSubmenu extends Menu

const TRANS_TIME: float = 0.1

var mode: String = "level up"
var can_advance: bool = false

signal advanced

func _ready() -> void:
	visible = false
	%SoulText.visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if mode == "status":
		if event.is_action_pressed("cancel", false):
			%CancelPlayer.play()
			exit(false)
		if event.is_action_pressed("menu", false):
			%CancelPlayer.play()
			exit(true)
	else:
		if can_advance and event.is_action_pressed("accept", false):
			%AcceptPlayer.play()
			advanced.emit()

func display_fighter_status(fighter: Fighter) -> void:
	%PanelContainer.visible = true
	%PanelContainer2.visible = false
	%FighterNameLabel.text = fighter.name
	%InfoLabel.text = "stats"
	%FighterIcon.texture = fighter.get_node("%Sprite2D").texture
	%MaxHPValLabel.text = str(fighter.stats.max_hp)
	%MaxTPValLabel.text = str(fighter.stats.max_tp)
	%StrValLabel.text = str(fighter.stats.strength)
	%MagValLabel.text = str(fighter.stats.magic)
	%DefValLabel.text = str(fighter.stats.defence)
	%LucValLabel.text = str(fighter.stats.luck)

func display_drops(soul_count: int) -> void:
	%PanelContainer.visible = false
	%PanelContainer2.visible = true
	
	%DropLabel.text = "the %s\ndropped:" % ["hooligans", "ruffians", "vandals", "foes", "wise guys"].pick_random()
	%SoulText.get_node("%Label").text = str(soul_count)
	
	await enter()
	%SoulText.visible = true
	can_advance = true
	%Flicker2.flicker()
	await advanced
	can_advance = false
	%Flicker2.stop() 
	%SoulText.visible = false
	await exit()

func display_level_ups(level_up_amount: int) -> void:
	%PanelContainer.visible = true
	%PanelContainer2.visible = false
	for i in range(Ref.player_party.get_child_count()):
		var fighter: Fighter = Ref.player_party.get_child(i)
		
		display_fighter_status(fighter)
		
		fighter.stats.strength += fighter.strength_grow * level_up_amount
		fighter.stats.magic += fighter.magic_grow * level_up_amount
		fighter.stats.defence += fighter.defence_grow * level_up_amount
		fighter.stats.luck += fighter.luck_grow * level_up_amount
		fighter.stats.max_hp += fighter.max_hp_grow * level_up_amount
		fighter.stats.max_tp += fighter.max_tp_grow * level_up_amount
		
		%MaxHPValLabelNew.text = str(fighter.stats.max_hp)
		%MaxTPValLabelNew.text = str(fighter.stats.max_tp)
		%StrValLabelNew.text = str(fighter.stats.strength)
		%MagValLabelNew.text = str(fighter.stats.magic)
		%DefValLabelNew.text = str(fighter.stats.defence)
		%LucValLabelNew.text = str(fighter.stats.luck)
		
		
		await enter()
		
		can_advance = true
		%Flicker.flicker()
		await advanced
		can_advance = false
		%Flicker.stop()
		
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(get_parent().material, "shader_parameter/fade", 1, TRANS_TIME)
		await tween.finished

func enter() -> void:
	if mode == "status":
		%ArrowContainer.visible = false
		%NewStatValueContainer.visible = false
	else:
		%ArrowContainer.visible = true
		%NewStatValueContainer.visible = true
	
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
