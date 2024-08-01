class_name Friend extends Character

@export var conversation: Array[Dialogue]

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)

func _on_interacted(interact_initiator: Character) -> void:
	interact_initiator.is_paused = true
	await Ref.world_textbox.display_conversation(conversation)
	interact_initiator.is_paused = false
