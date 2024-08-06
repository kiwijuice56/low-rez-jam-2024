class_name Shopkeep extends Friend

@export var reject_conversation: Array[Dialogue]
@export var done_conversation: Array[Dialogue]

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)

func _on_interacted(_interact_initiator: Character) -> void:
	if Ref.world.is_paused:
		return
	Ref.world.is_paused = true
	await Ref.world_textbox.display_conversation(conversation)
	var choice: String = await Ref.world_textbox.get_choice(["yes", "no"] as Array[String])
	if choice == "no":
		await Ref.world_textbox.display_conversation(reject_conversation, false) 
		await Ref.world_textbox.exit()
	else:
		await Ref.transition.trans_in()
		Ref.shop_menu.enter()
		await Ref.world_textbox.exit()
		await Ref.transition.trans_out()
		await Ref.shop_menu.shop()
		await Ref.transition.trans_in()
		Ref.shop_menu.exit()
		await Ref.transition.trans_out()
		await Ref.world_textbox.display_conversation(done_conversation, true) 
		await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)
