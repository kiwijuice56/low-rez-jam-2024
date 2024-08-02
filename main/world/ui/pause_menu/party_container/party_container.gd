class_name PartyContainer extends Menu

signal advanced(input: String)

var choice_idx: int = 0

func _ready() -> void:
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept", false):
		advanced.emit("accept")
	if event.is_action_pressed("cancel", false):
		advanced.emit("cancel")
	if event.is_action_pressed("menu", false):
		advanced.emit("menu")
	var old_idx: int = choice_idx
	if event.is_action_pressed("up", false):
		%SelectPlayer.play()
		choice_idx -= 1
	if event.is_action_pressed("down", false):
		%SelectPlayer.play()
		choice_idx += 1
	choice_idx = (choice_idx + get_child_count()) % get_child_count()
	if not old_idx == choice_idx:
		update_selection(old_idx)

func accept() -> void:
	pass

func update_selection(old_idx: int) -> void:
	get_child(old_idx).unhover()
	get_child(choice_idx).hover()

func check_status() -> bool:
	choice_idx = 0
	get_child(0).hover()
	 
	set_process_input(true)
	var input: String = await advanced
	if input == "accept":
		pass
	if input == "cancel" or input == "menu":
		%CancelPlayer.play()
		set_process_input(true)
		get_child(choice_idx).unhover()
		return input == "menu"
	return false
