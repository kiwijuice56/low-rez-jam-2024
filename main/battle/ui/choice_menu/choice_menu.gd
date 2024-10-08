class_name ChoiceMenu extends Menu

const MOVE_SPEED: float = 12.0
const BUTTON_WIDTH: int = 10

@export var choice_button_scene: PackedScene

var choice_count: int
var cancel_enabled: bool
var idx: int

var initial_x: float
var internal_x: float
var target_x: float

var mini_visible: bool = true

signal advanced(accepted: bool)

func _ready() -> void:
	set_process_input(false)
	set_process(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		%SelectPlayer.play()
		idx += 1
		update_info()
	if event.is_action_pressed("left"):
		%SelectPlayer.play()
		idx -= 1
		update_info()
	if event.is_action_pressed("accept", false):
		test_accept()
	if event.is_action_pressed("cancel", false) and cancel_enabled:
		%CancelPlayer.play()
		advanced.emit(false)
	target_x = -(idx + choice_count - 2) * BUTTON_WIDTH

func _process(delta: float) -> void:
	internal_x = lerp(internal_x, target_x, MOVE_SPEED * delta)
	update_position()
	
	for i in range(3 * choice_count):
		%ChoiceContainer.get_child(i).is_hovered = false
	var min_dist: float = 1000
	var candidate: ChoiceButton
	for i in range(3 * choice_count):
		if not i % choice_count == posmod(idx, choice_count):
			continue 
		var new_dist: float = %ChoiceContainer.get_child(i).global_position.distance_to(%Center.global_position + Vector2(BUTTON_WIDTH, 0))
		if new_dist < min_dist:
			candidate = %ChoiceContainer.get_child(i)
			min_dist = new_dist
	candidate.is_hovered = true

func mini_trans_in() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%ChoiceContainer, "position:y", 46, 0.05)
	await tween.finished
	mini_visible = true

func mini_trans_out() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%ChoiceContainer, "position:y", 46 + 10, 0.05)
	await tween.finished
	mini_visible = false

func update_info() -> void:
	var selected: ChoiceButton = %ChoiceContainer.get_child(posmod(idx, choice_count))
	%ChoiceLabel.text = selected.action_name
	%CostAmountLabel.text = selected.cost_name
	%CostColoredText.get_node("%Label").text = selected.cost_amount
	
	if selected.action and selected.action.is_item:
		%CostText.text = selected.cost_amount
		%CostText.visible = true
		%CostColoredText.visible = false
	else:
		%CostText.visible = false
		%CostColoredText.visible = true
	
	if len(selected.description) > 0:
		Ref.battle_text.display_text(selected.description, Ref.battle.TEXT_SPEED)

func update_position() -> void:
	%ChoiceContainer.global_position.x = initial_x + fposmod(internal_x, BUTTON_WIDTH * choice_count)

func test_accept() -> void:
	if not %ChoiceContainer.get_child(posmod(idx, choice_count)).is_disabled:
		%AcceptPlayer.play()
		advanced.emit(true)
	else:
		%ErrorPlayer.play()

func initialize(initial_idx: int, can_cancel: bool, buttons: Array[ChoiceButton]) -> void:
	choice_count = len(buttons)
	idx = initial_idx
	cancel_enabled = can_cancel
	
	initial_x = %Center.global_position.x - BUTTON_WIDTH * (choice_count + 1)
	target_x = -(initial_idx + choice_count - 2) * BUTTON_WIDTH
	internal_x = target_x
	
	for child in %ChoiceContainer.get_children():
		%ChoiceContainer.remove_child(child)
		child.queue_free()
	for i in range(3):
		for button in buttons:
			var new_button: ChoiceButton = button.duplicate()
			%ChoiceContainer.add_child(new_button)
	
	%ChoiceContainer.get_child(choice_count + initial_idx).is_hovered = true
	update_info()
	update_position.call_deferred()

func get_choice() -> ChoiceButton:
	set_process(true)
	set_process_input(true)
	
	var accepted: bool = await advanced
	
	set_process_input(false)
	set_process(false)
	
	if not accepted:
		return null
	%ChoiceContainer.get_child(posmod(idx, choice_count)).idx = posmod(idx, choice_count)
	return %ChoiceContainer.get_child(posmod(idx, choice_count))
