class_name Recruit extends Character

@export var fighter_scene: PackedScene
@export var conversation: Array[Dialogue]

var collected: bool = false

func _ready() -> void:
	if Data.get_state(Ref.world.loaded_room_name + "/" + name, false):
		set_collected()
	if not collected:
		%Interactable.interacted.connect(_on_interacted)

func _on_interacted(_interact_initiator: Character) -> void:
	Ref.world.is_paused = true
	Data.set_state(Ref.world.loaded_room_name + "/" + name, true)
	Ref.player_party.add_member(fighter_scene)
	await Ref.world_textbox.enter()
	await Ref.world_textbox.display_conversation(conversation)
	await Ref.world_textbox.exit()
	Ref.world.set_deferred("is_paused", false)
	
	set_collected()

func set_collected() -> void:
	queue_free()
