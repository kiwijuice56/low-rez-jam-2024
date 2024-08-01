class_name TextBox extends Menu
# For overworld use, not combat

const SPEED_MAP: Dictionary = {"Normal": 48, "Slow": 24, "Fast": 72}

signal continued

func _ready() -> void:
	%AnimatedTextLabel.display_text("hey you hungry home invader... stop raiding our frigerator!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		continued.emit()

func display_conversation(dialogues: Array[Dialogue]) -> void:
	for dialogue in dialogues:
		await %AnimatedTextLabel.display_text(dialogue.text, SPEED_MAP[dialogue.speed])
		await continued
