class_name ItemPickup extends Area2D

const NUM_MAP: Array[String] = ["one", "two", "three", "four", "five"]

@export var item: String
@export var amount: int = 1
@export var conversation: Array[Dialogue]

var collected: bool = false

func _ready() -> void:
	if Data.get_state(Ref.world.loaded_room_name + "/" + name, false):
		set_collected()
	if not collected:
		%Interactable.interacted.connect(_on_interacted)
		conversation = conversation.duplicate(true)
		conversation[1] = conversation[1].duplicate(true)
		if amount == 1:
			conversation[1].text = "you got a %s." % [item]
		else:
			conversation[1].text = "you got %s %ss." % [NUM_MAP[amount - 1], item]

func _on_interacted(_interact_initiator: Character) -> void:
	Ref.world.is_paused = true
	Data.set_state(Ref.world.loaded_room_name + "/" + name, true)
	Data.set_state(item, Data.get_state(item, 0) + amount)
	await Ref.world_textbox.enter()
	await Ref.world_textbox.display_conversation(conversation)
	set_collected()
	await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)

func set_collected() -> void:
	collected = true
	%Interactable.can_interact = false
	%ItemSmoke.emitting = false
	%ItemSprite.visible = false
