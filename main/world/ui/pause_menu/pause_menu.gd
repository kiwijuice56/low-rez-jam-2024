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
		%CancelPlayer.play()
		exit(false)
	var old_idx: int = choice_idx
	if event.is_action_pressed("up", false):
		%SelectPlayer.play()
		choice_idx -= 1
	if event.is_action_pressed("down", false):
		%SelectPlayer.play()
		choice_idx += 1
	choice_idx = (choice_idx + %ChoiceContainer.get_child_count()) % %ChoiceContainer.get_child_count()
	if not old_idx == choice_idx:
		update_selection(old_idx)

func accept() -> void:
	set_process_input(false)
	revoke_highlight()
	
	match choice_idx:
		0: 
			%AcceptPlayer.play()
			var full_exit: bool = await %PartyContainer.check_status()
			if full_exit:
				exit(true)
			else:
				set_process_input(true)
		1: 
			%AcceptPlayer.play()
			var full_exit: bool = await %PartyContainer.swap()
			if full_exit:
				exit(true)
			else:
				set_process_input(true)
		2:
			%TipContainer.hide_tip()
			
			%AcceptPlayer.play()
			%LevelSubmenu.enter()
			var full_exit: bool = await %LevelSubmenu.exited
			if full_exit:
				exit(true)
			else:
				set_process_input(true)
				%TipContainer.show_tip()
				update_top_tip()
		3: 
			%TipContainer.hide_tip()
			
			%AcceptPlayer.play()
			%ItemSubmenu.enter()
			var full_exit: bool = await %ItemSubmenu.exited
			if full_exit:
				exit(true)
			else:
				set_process_input(true)
				%TipContainer.show_tip()
				update_top_tip()
		4: pass
	
	update_selection(-1)

func initialize() -> void:
	for child in %PartyContainer.get_children():
		%PartyContainer.remove_child(child)
		child.queue_free()
	for child in Ref.player_party.get_children():
		var new_panel: PartyMemberPanel = party_member_panel_scene.instantiate()
		%PartyContainer.add_child(new_panel)
		new_panel.initialize(child)

func update_selection(old_idx: int) -> void:
	if old_idx >= 0:
		%ChoiceContainer.get_child(old_idx).add_theme_color_override("font_color", default_color)
	%ChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", select_color)
	if old_idx >= 0:
		%FlickerContainer.get_child(old_idx).stop()
	%FlickerContainer.get_child(choice_idx).flicker()
	update_top_tip()

func update_top_tip() -> void:
	match choice_idx:
		0:
			%TipLabel.text = "see party stats"
		1:
			%TipLabel.text = "swap your party"
		2:
			%TipLabel.text = "see level + xp"
		3:
			%TipLabel.text = "see your items"
		4:
			%TipLabel.text = "change settings"

func revoke_highlight() -> void:
	%ChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", default_color)

func add_highlight() -> void:
	%ChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", select_color)

func enter() -> void:
	Ref.world.is_paused = true
	
	%AcceptPlayer.play()
	%TipContainer.show_tip()
	update_top_tip()
	
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
	
	%TipContainer.hide_tip()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	
	Ref.world.is_paused = false
	exited.emit(full_exit)
