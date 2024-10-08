class_name PressTurnWidget extends Node2D

const TURN_WIDTH: int = 4

@export var press_turn_scene: PackedScene

var turn_count: int
var flash_idx: int

func initialize(full_turns: int, player: bool) -> void:
	turn_count = full_turns
	flash_idx = full_turns - 1
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for i in range(full_turns):
		var new_turn: PressTurn = press_turn_scene.instantiate()
		add_child(new_turn)
		new_turn.position.x = i * TURN_WIDTH
		new_turn.initialize(player)

func waste_turns(amount: int) -> void:
	for i in range(min(get_child_count(), amount)):
		if i == amount - 1:
			await get_child(turn_count - 1 - i).waste()
		else:
			get_child(turn_count - 1 - i).waste()
	turn_count -= amount
	flash_idx = min(flash_idx, turn_count - 1)

func flash_turn() -> void:
	await get_child(flash_idx).start_flashing()
	flash_idx -= 1
