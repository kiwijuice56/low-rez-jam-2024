class_name Enemy extends Character

@export var movement: bool = false
@export var recruit_scene: PackedScene
@export var encounter: Encounter
@export var requires_interact: bool
@export var conversation: Array[Dialogue]
@export var death_conversation: Array[Dialogue]

@export var move_time: float = 1.2

signal died

func _ready() -> void:
	if Data.get_state(Ref.world.loaded_room_name + "/" + name, false):
		queue_free()
	
	if requires_interact:
		%Interactable.interacted.connect(_on_interacted)
	else:
		# slightly differeng - using the interactable area here
		# just resuing nodes :/
		%Interactable.area_entered.connect(_on_area_entered)
	%MoveTimer.timeout.connect(_on_movement_timer)
	%MoveTimer.start(move_time)

func _on_movement_timer() -> void:
	%MoveTimer.start(move_time)
	if Ref.world.is_paused or not movement:
		return
	await move(DIR_MAP.values().pick_random())

func _on_area_entered(_area: Area2D) -> void:
	start_battle()

func _on_interacted(_interact_initiator: Character) -> void:
	start_battle()

func start_battle() -> void:
	if Ref.world.is_paused:
		return
	
	Ref.world.is_paused = true
	if conversation:
		await Ref.world_textbox.display_conversation(conversation)
	%EncounterSound.play()
	
	if await Ref.battle.battle(encounter):
		await die()

func die() -> void:
	if death_conversation:
		if recruit_scene:
			Ref.player_party.add_member(recruit_scene)
		await Ref.world_textbox.display_conversation(death_conversation)
		await Ref.world_textbox.exit()
	Data.set_state(Ref.world.loaded_room_name + "/" + name, true)
	Ref.world.set_deferred("is_paused", false)
	died.emit()
	queue_free()
