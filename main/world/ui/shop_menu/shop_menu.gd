class_name ShopMenu extends Menu

const TRANS_TIME: float = 0.1

@export var confirm_conversation: Array[Dialogue]
@export var already_owned_conversation: Array[Dialogue]
@export var not_enough_conversation: Array[Dialogue]

var screens: Array[Dictionary]
var screen_idx: int = 0

signal continued(accepted: bool)

func _ready() -> void:
	set_process_input(false)
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		%AcceptPlayer.play()
		continued.emit(true)
	if event.is_action_pressed("cancel", false):
		%CancelPlayer.play()
		continued.emit(false)
	var old_idx: int = screen_idx
	if event.is_action_pressed("right", false):
		screen_idx += 1
		%SelectPlayer.play()
	if event.is_action_pressed("left", false):
		screen_idx -= 1
		%SelectPlayer.play()
	screen_idx = (screen_idx + len(screens)) % len(screens)
	if not screen_idx == old_idx:
		refocus()

func refocus() -> void:
	initialize(screens[screen_idx].fighter, screens[screen_idx].action)

func initialize(fighter: Fighter, action: Action) -> void:
	%SoulText.get_node("%Label").text = " " + str(Data.get_state("souls", 0))
	
	if action.get_index() in fighter.stats.unlocked_skills:
		%BoughtLabel.visible = true
		%PriceText.visible = false
	else:
		%BoughtLabel.visible = false
		%PriceText.get_node("%Label").text = " " + str(action.soul_cost)
		%PriceText.visible = true
	
	%SkillNameLabel.text = action.name
	%FighterIcon.texture = fighter.get_node("%Sprite2D").texture
	%FighterNameLabel.text = fighter.name
	%Description.text = action.description
	
	%ChoiceButton.initialize_other(action.name, action.icon)

func initialize_screens() -> void:
	screens = []
	for fighter in Ref.player_party.get_children():
		for skill in fighter.get_node("%Skills").get_children():
			screens.append({"fighter": fighter, "action": skill})

func enter() -> void:
	screen_idx = 0
	initialize_screens()
	refocus()
	visible = true
	entered.emit()

func shop() -> void:
	set_process_input(true)
	
	while true:
		var accepted: bool = await continued
		if accepted:
			set_process_input(false)
			await buy()
			set_process_input(true)
		else:
			break
	
	set_process_input(false)

func buy() -> void:
	var fighter: Fighter = screens[screen_idx].fighter
	var action: Action = screens[screen_idx].action
	
	if action.get_index() in fighter.stats.unlocked_skills:
		await Ref.world_textbox.display_conversation(already_owned_conversation)
		await Ref.world_textbox.exit()
		return
	
	if Data.get_state("souls", 0) < action.soul_cost:
		await Ref.world_textbox.display_conversation(not_enough_conversation)
		await Ref.world_textbox.exit()
		return
	
	await Ref.world_textbox.display_conversation(confirm_conversation)
	var choice: String = await Ref.world_textbox.get_choice(["yes", "no"] as Array[String])
	await Ref.world_textbox.exit()
	
	if choice == "yes":
		Data.set_state("souls", Data.get_state("souls", 0) - action.soul_cost)
		fighter.stats.unlocked_skills.append(action.get_index())
		refocus()
	else:
		pass # cancel sound ? maybe

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	visible = false
	exited.emit(full_exit)
