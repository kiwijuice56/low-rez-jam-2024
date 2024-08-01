class_name ItemSubmenu extends Menu

@export var item_label_scene: PackedScene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel", false):
		exit(false)
	if event.is_action_pressed("menu", false):
		exit(true)

func display_items() -> void:
	for label in %ItemContainer.get_children() + %AmountContainer.get_children():
		label.queue_free()
	for item in Data.get_state("inventory"):
		var amount: int = Data.get_state("inventory/" + item)
		var new_label: Label = item_label_scene.instantiate()
		new_label.text = item
		%ItemContainer.add_child(new_label)
		
		new_label = item_label_scene.instantiate()
		new_label.text = "x%d" % amount
		%AmountContainer.add_child(new_label)

func enter() -> void:
	display_items()
	super.enter()
	set_process_input(true)

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	super.exit(full_exit)
