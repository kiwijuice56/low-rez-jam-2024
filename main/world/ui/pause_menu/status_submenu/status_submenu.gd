class_name StatusSubmenu extends Menu

const TRANS_TIME: float = 0.1

func _ready() -> void:
	visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel", false):
		exit(false)
	if event.is_action_pressed("menu", false):
		exit(true)

func display_fighter_status(fighter: Fighter) -> void:
	%FighterNameLabel.text = fighter.name
	%InfoLabel.text = "status"
	%FighterIcon.texture = fighter.get_node("%Sprite2D").texture
	%MaxHPValLabel.text = str(fighter.stats.max_hp)
	%MaxTPValLabel.text = str(fighter.stats.max_tp)
	%StrValLabel.text = str(fighter.stats.strength)
	%MagValLabel.text = str(fighter.stats.magic)
	%DefValLabel.text = str(fighter.stats.defence)
	%LucValLabel.text = str(fighter.stats.luck)

func enter() -> void:
	get_parent().material.set_shader_parameter("fade", 1.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
	await tween.finished
	
	set_process_input(true)
	entered.emit()

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	
	%CancelPlayer.play()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	
	exited.emit(full_exit)
