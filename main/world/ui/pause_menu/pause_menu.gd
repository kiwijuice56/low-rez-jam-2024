class_name PauseMenu extends Menu

const TRANS_TIME: float = 0.1

@export var party_member_panel_scene: PackedScene
@export var default_color: Color
@export var select_color: Color

var choice_idx: int = 0

func _ready() -> void:
	set_process_input(false)
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		accept()
	if event.is_action_pressed("cancel", false) or event.is_action_pressed("menu", false):
		exit(false)
	var old_idx: int = choice_idx
	if event.is_action_pressed("up", false):
		choice_idx -= 1
	if event.is_action_pressed("down", false):
		choice_idx += 1
	choice_idx = (choice_idx + %ChoiceContainer.get_child_count()) % %ChoiceContainer.get_child_count()
	if not old_idx == choice_idx:
		update_selection(old_idx)

func accept() -> void:
	set_process_input(false)
	
	match choice_idx:
		0: pass
		1: pass
		2: 
			%ItemSubmenu.enter()
			var full_exit: bool = await %ItemSubmenu.exited
			if full_exit:
				exit(true)
			else:
				set_process_input(true)
		3: pass

func initialize() -> void:
	for child in %PartyContainer.get_children():
		child.queue_free()
	for child in Ref.player_party.get_children():
		var new_panel: PartyMemberPanel = party_member_panel_scene.instantiate()
		%PartyContainer.add_child(new_panel)
		new_panel.initialize(child)

func update_selection(old_idx: int) -> void:
	%ChoiceContainer.get_child(old_idx).add_theme_color_override("font_color", default_color)
	%ChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", select_color)
	%FlickerContainer.get_child(old_idx).stop()
	%FlickerContainer.get_child(choice_idx).flicker()

func enter() -> void:
	Ref.world.is_paused = true
	
	initialize()
	
	var old_idx: int = choice_idx
	choice_idx = 0
	update_selection(old_idx)
	
	get_parent().material.set_shader_parameter("fade", 1.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
	await tween.finished
	
	set_process_input(true)
	
	entered.emit()

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	
	get_parent().material.set_shader_parameter("fade", 0.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	
	Ref.world.is_paused = false
	exited.emit(full_exit)
