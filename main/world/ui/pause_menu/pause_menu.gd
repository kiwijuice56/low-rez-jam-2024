class_name PauseMenu extends Menu

@export var party_member_panel_scene: PackedScene

var choice_idx: int = 0

func _ready() -> void:
	exit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel", false) or event.is_action_pressed("menu", false):
		close_menu()
	var old_idx: int = choice_idx
	if event.is_action_pressed("up", false):
		choice_idx -= 1
	if event.is_action_pressed("down", false):
		choice_idx += 1
	choice_idx = (choice_idx + %ChoiceContainer.get_child_count()) % %ChoiceContainer.get_child_count()
	if not old_idx == choice_idx:
		update_selection(old_idx)

func initialize() -> void:
	for child in %PartyContainer.get_children():
		child.queue_free()
	for child in Ref.player_party.get_children():
		var new_panel: PartyMemberPanel = party_member_panel_scene.instantiate()
		%PartyContainer.add_child(new_panel)
		new_panel.initialize(child)

func update_selection(old_idx: int) -> void:
	%FlickerContainer.get_child(old_idx).stop()
	%FlickerContainer.get_child(choice_idx).flicker()

func open_menu() -> void:
	var old_idx: int = choice_idx
	choice_idx = 0
	update_selection(old_idx)
	Ref.world.is_paused = true
	initialize()
	enter()

func close_menu() -> void:
	exit()
	Ref.world.is_paused = false

func enter() -> void:
	super.enter()
	set_process_input(true)

func exit() -> void:
	super.exit()
	set_process_input(false)
