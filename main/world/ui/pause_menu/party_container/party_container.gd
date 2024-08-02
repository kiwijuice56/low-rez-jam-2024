class_name PartyContainer extends Menu

signal advanced(input: String)

var choice_idx: int = 0
var selected_idx: int = -1

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

func check_status(initial_index: int = 0) -> bool:
	choice_idx = initial_index
	get_child(initial_index).hover()
	 
	%TipLabel.text = "check on who?"
	
	set_process_input(true)
	var input: String = await advanced
	if input == "accept":
		%TipContainer.hide_tip()
		%AcceptPlayer.play()
		set_process_input(false)
		%StatusSubmenu.display_fighter_status(get_child(choice_idx).fighter)
		await %StatusSubmenu.enter()
		var full_exit: bool = await %StatusSubmenu.exited
		if full_exit:
			set_process_input(false)
			get_child(choice_idx).unhover()
			return true
		%TipContainer.show_tip()
		%TipLabel.text = "check on who?"
		return await check_status(choice_idx)
	if input == "cancel" or input == "menu":
		%CancelPlayer.play()
		set_process_input(false)
		get_child(choice_idx).unhover()
		return input == "menu"
	return false

func swap(initial_index: int = 0) -> bool:
	choice_idx = initial_index
	get_child(initial_index).hover()
	 
	%TipLabel.text = "swap who?"
	
	set_process_input(true)
	var input: String = await advanced
	if input == "accept":
		%AcceptPlayer.play()
		selected_idx = choice_idx
		get_child(selected_idx).select()
		
		var full_exit: bool = await swap_second()
		set_process_input(false)
		get_child(choice_idx).unhover()
		return full_exit
	if input == "cancel" or input == "menu":
		%CancelPlayer.play()
		set_process_input(false)
		get_child(choice_idx).unhover()
		return input == "menu"
	return false

func swap_second() -> bool:
	%TipLabel.text = "and who else?"
	choice_idx = 0
	get_child(choice_idx).hover()
	
	set_process_input(true)
	var input: String = await advanced
	
	get_child(selected_idx).deselect()
	
	if input == "menu":
		%CancelPlayer.play()
		return true
	if input == "cancel":
		%CancelPlayer.play()
		return await swap(selected_idx)
	if input == "accept":
		# perform swap
		%AcceptPlayer.play()
		return await swap(choice_idx)
	
	return false
