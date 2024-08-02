class_name Door extends Area2D

@export var target_room: String
@export var target_anchor: String = "Default"
@export var requires_interact: bool = true

func _ready() -> void:
	if requires_interact:
		%Interactable.interacted.connect(_on_interacted)
	else:
		area_entered.connect(_on_area_entered)

func _on_area_entered(_area: Area2D) -> void:
	if Ref.world.is_paused:
		return
	Ref.world.load_room(target_room, target_anchor)

func _on_interacted(_interact_initiator: Character) -> void:
	Ref.world.load_room(target_room, target_anchor)
