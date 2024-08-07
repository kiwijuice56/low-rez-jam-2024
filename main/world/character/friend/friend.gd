class_name Friend extends Character

@export var conversation: Array[Dialogue]

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)

func _on_interacted(_interact_initiator: Character) -> void:
	if Ref.world.is_paused:
		return
	Ref.world.is_paused = true
	await Ref.world_textbox.display_conversation(conversation)
	await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)
