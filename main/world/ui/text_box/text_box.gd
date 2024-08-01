class_name TextBox extends Menu
# For overworld use, not combat

const TRANS_TIME: float = 0.1
const SPEED_MAP: Dictionary = {"Normal": 1.0, "Slow": 0.5, "Fast": 2.0}

signal continued

var odd_character: bool = false

func _ready() -> void:
	%AnimatedTextLabel.char_advanced.connect(_on_char_advanced)
	exit(false)

func _on_char_advanced() -> void:
	odd_character = not odd_character
	if not odd_character:
		return
	%CharSoundPlayer.stop()
	%CharSoundPlayer.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false) or event.is_action_pressed("cancel", false):
		continued.emit()

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
		await continued
		%Flicker.stop()

func exit(full_exit: bool = false) -> void:
	get_parent().material.set_shader_parameter("fade", 0.0)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	exited.emit(full_exit)
