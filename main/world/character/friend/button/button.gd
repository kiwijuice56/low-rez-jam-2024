class_name FriendButton extends Friend

@export var press_conversation: Array[Dialogue]
@onready var key: String = Ref.world.loaded_room_name + "/" + name

signal pressed

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)
	update_state()

func _on_interacted(_interact_initiator: Character) -> void:
	if Data.get_state(Ref.world.loaded_room_name + "/" + name, false):
		return
	if Ref.world.is_paused:
		return
	Ref.world.is_paused = true
	await Ref.world_textbox.display_conversation(conversation)
	var choice: String = await Ref.world_textbox.get_choice(["yes", "no"] as Array[String])
	if choice == "no":
		pass
	else:
		Data.set_state(Ref.world.loaded_room_name + "/" + name, true)
		update_state()
		pressed.emit()
		await Ref.world_textbox.display_conversation(press_conversation)
	await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)

func update_state() -> void:
	if Data.get_state(Ref.world.loaded_room_name + "/" + name, false):
		%Sprite2D.frame = 1
	else:
		%Sprite2D.frame = 0
