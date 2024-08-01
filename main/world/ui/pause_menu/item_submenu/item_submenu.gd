class_name ItemSubmenu extends Menu

const TRANS_TIME: float = 0.1

@export var item_label_scene: PackedScene

func _ready() -> void:
	visible = false
	set_process_input(false)

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
	
	get_parent().material.set_shader_parameter("fade", 1.0)
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 0, TRANS_TIME)
	await tween.finished
	
	set_process_input(true)
	entered.emit()

func exit(full_exit: bool = false) -> void:
	set_process_input(false)
	
	%CancelPlayer.play()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(get_parent().material, "shader_parameter/fade", 1.0, TRANS_TIME)
	await tween.finished
	
	exited.emit(full_exit)
