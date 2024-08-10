class_name TombstoneHandler extends Node2D

@export var tombstone: PackedScene = preload("res://main/world/room/god_house/tombstone.tscn")

func _ready() -> void:
	for child in get_children():
		child.queue_free()
		remove_child(child)
	for i in range(Data.get_state("kills", 0)):
		if i >= 28:
			return
		
		var new_stone: Sprite2D = tombstone.instantiate()
		add_child(new_stone)
		new_stone.global_position = %Start.global_position + Vector2(9, 0) * i
