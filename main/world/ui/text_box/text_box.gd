class_name TextBox extends Menu
# For overworld use, not combat

const TRANS_TIME: float = 0.1
const SPEED_MAP: Dictionary = {"Normal": 1.0, "Slow": 0.5, "Fast": 2.0}

signal continued

@export var label_scene: PackedScene
@export var flicker_scene: PackedScene
@export var default_color: Color
@export var select_color: Color

var odd_character: bool = false
var choice_idx: int = 0
var choice_size: int = 0

func _ready() -> void:
	%AnimatedTextLabel.char_advanced.connect(_on_char_advanced)
	%ChoiceContainer.visible = false
	exit(false)
	set_process_input(false)

func _on_char_advanced() -> void:
	odd_character = not odd_character
	if not odd_character:
		return
	%CharSoundPlayer.stop()
	%CharSoundPlayer.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false) or event.is_action_pressed("cancel", false):
		continued.emit()
	if choice_size == 0:
		return
	var old_idx: int = choice_idx
	if choice_size > 0 and event.is_action_pressed("up", false):
		choice_idx -= 1
		%SelectPlayer.play()
	if choice_size > 0 and event.is_action_pressed("down", false):
		choice_idx += 1
		%SelectPlayer.play()
	choice_idx = (choice_idx + choice_size) % choice_size
	if not choice_idx == old_idx:
		refocus(old_idx)

func display_conversation(dialogues: Array[Dialogue], trans_in: bool = true) -> void:
	var passed_first_dialogue = false
	for dialogue in dialogues:
		odd_character = false
		
		%SpeakerPortrait.visible = dialogue.speaker.portrait != null
		%SpeakerPortrait.texture = dialogue.speaker.portrait
		%CharSoundPlayer.stream = dialogue.speaker.voice
		
		if not passed_first_dialogue and trans_in:
			%AnimatedTextLabel.visible_characters = 0
			get_parent().material.set_shader_parameter("fade", 1.0)
			visible = true
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
			await tween.finished
		
		passed_first_dialogue = true
		
		var chars_per_second: int = int(SPEED_MAP[dialogue.speed] * dialogue.speaker.chars_per_second)
		await %AnimatedTextLabel.display_text(dialogue.text, chars_per_second)
		%Flicker.flicker()
		set_process_input(true)
		await continued
		%ContinuePlayer.play()
		set_process_input(false)
		%Flicker.stop()

func refocus(old_idx: int) -> void:
	if old_idx >= 0:
		%TextChoiceContainer.get_child(old_idx).add_theme_color_override("font_color", default_color)
	%TextChoiceContainer.get_child(choice_idx).add_theme_color_override("font_color", select_color)
	if old_idx >= 0:
		%FlickerContainer.get_child(old_idx).stop()
	%FlickerContainer.get_child(choice_idx).flicker()

func get_choice(choices: Array[String]) -> String:
	for child in %FlickerContainer.get_children() + %TextChoiceContainer.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	
	choice_idx = 0
	choice_size = len(choices)
	
	for i in range(choice_size):
		var new_flicker: Flicker = flicker_scene.instantiate()
		%FlickerContainer.add_child(new_flicker)
		var new_label: Label = label_scene.instantiate()
		new_label.text = choices[i]
		%TextChoiceContainer.add_child(new_label)
	
	refocus(-1)
	
	%ChoiceVBox.position.y = %Background.size.y + 1
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%ChoiceVBox, "position:y", 0, TRANS_TIME)
	%ChoiceContainer.visible = true
	await tween.finished
	set_process_input(true)
	
	await continued
	
	set_physics_process(false)
	
	%ContinuePlayer.play()
	
	tween = get_tree().create_tween()
	tween.tween_property(%ChoiceVBox, "position:y", %Background.size.y + 1, TRANS_TIME)
	
	await tween.finished
	%ChoiceContainer.visible = false
	
	choice_size = 0
	
	return choices[choice_idx]

func exit(full_exit: bool = false) -> void:
	get_parent().material.set_shader_parameter("fade", 0.0)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	exited.emit(full_exit)
