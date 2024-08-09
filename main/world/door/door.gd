class_name Door extends Area2D

@export var door_sprite: Texture = preload("res://main/world/door/door.png")
@export var target_room: String
@export var target_anchor: String = "Default"
@export var requires_interact: bool = true
@export_enum("up", "down", "left", "right") var out_direction: String = "up"

func _ready() -> void:
	%Sprite2D.texture = door_sprite
	if requires_interact:
		%Interactable.interacted.connect(_on_interacted)
	else:
		area_entered.connect(_on_area_entered)

func _on_area_entered(_area: Area2D) -> void:
	if Ref.world.is_paused:
		return
	open()

func _on_interacted(_interact_initiator: Character) -> void:
	open()

func open() -> void:
	Ref.world.is_paused = true
	%AnimationPlayer.play("open")
	await %AnimationPlayer.animation_finished
	Ref.world.load_room(target_room, target_anchor, true, out_direction)
