class_name TextBox extends Menu
# For overworld use, not combat

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

func display_conversation(dialogues: Array[Dialogue]) -> void:
	for dialogue in dialogues:
		odd_character = false
		
		%SpeakerPortrait.visible = dialogue.speaker.portrait != null
		%SpeakerPortrait.texture = dialogue.speaker.portrait
		%CharSoundPlayer.stream = dialogue.speaker.voice
		
		var chars_per_second: int = int(SPEED_MAP[dialogue.speed] * dialogue.speaker.chars_per_second)
		await %AnimatedTextLabel.display_text(dialogue.text, chars_per_second)
		%Flicker.flicker()
		await continued
		%Flicker.stop()
