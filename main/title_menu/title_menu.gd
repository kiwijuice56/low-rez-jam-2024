class_name TitleMenu extends Menu

@export var default_color: Color
@export var select_color: Color

var choice_idx: int = 0

signal choice_made(new_game: bool)

func _ready() -> void:
	update_selection(-1)
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		accept()
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

func update_selection(old_idx: int) -> void:
	if old_idx >= 0:
		%ChoiceContainer.get_child(old_idx).add_theme_color_override("font_color", default_color)
	%ChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", select_color)
	if old_idx >= 0:
		%FlickerContainer.get_child(old_idx).stop()
	%FlickerContainer.get_child(choice_idx).flicker()

func accept() -> void:
	if choice_idx == 0:
		%AcceptPlayer.play()
		choice_made.emit(true)
		set_process_input(false)
	else:
		if Data.game_exists():
			%AcceptPlayer.play()
			choice_made.emit(false)
			set_process_input(false)
		else:
			%ErrorPlayer.play()

func enter() -> void:
	await Ref.transition.trans_out()
	await get_tree().create_timer(4.5).timeout
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	%MusicPlayer.play()
	tween.tween_property(%ControlCanvasGroup.material, "shader_parameter/fade", 1.0, 0.2)
	tween.tween_property(%MusicPlayer, "volume_db", -8, 0.2)
	await tween.finished
	
	set_process_input(true)

func exit(_full_exit: bool = false) -> void:
	visible = false
	set_process_input(false)
	exited.emit()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($MusicPlayer, "volume_db", -60, 2.0)
