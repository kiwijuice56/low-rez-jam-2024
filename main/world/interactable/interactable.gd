class_name Interactable extends Area2D

signal interacted

@export var requires_facing: bool = false
var interact_initiator: Character

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if not area is Character:
		return
	area.targeted_interactable = self
	interact_initiator = area

func _on_area_exited(area: Area2D) -> void:
	if not area is Character:
		return
	if area.targeted_interactable == self:
		area.targeted_interactable = null
	interact_initiator = null

func _input(event: InputEvent) -> void:
	if not is_instance_valid(interact_initiator):
		return
	if not interact_initiator.targeted_interactable == self:
		return
	if interact_initiator.is_paused or interact_initiator.in_movement:
		return
	var displacement: Vector2 = interact_initiator.global_position.direction_to(global_position).snapped(Vector2(1, 1))
	print(displacement)
	if requires_facing and not displacement.is_equal_approx(interact_initiator.facing_dir):
		return 
	if event.is_action_pressed("accept", false):
		interacted.emit(interact_initiator)
