class_name Saver extends Friend

@export var reject_conversation: Array[Dialogue]
@export var done_conversation: Array[Dialogue]

@export var room: String
@export var anchor: String

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)

func _on_interacted(_interact_initiator: Character) -> void:
	Ref.world.is_paused = true
	await Ref.world_textbox.display_conversation(conversation)
	var choice: String = await Ref.world_textbox.get_choice(["yes", "no"] as Array[String])
	if choice == "no":
		await Ref.world_textbox.display_conversation(reject_conversation, false) 
		await Ref.world_textbox.exit()
	else:
		await Ref.world_textbox.display_conversation(done_conversation, false) 
		Data.set_state("room", room)
		Data.set_state("anchor", anchor)
		Data.save_state(0)
		await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)
