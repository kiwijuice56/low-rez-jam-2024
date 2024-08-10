class_name Main extends Node

func _ready() -> void:
	randomize()
	Ref.world.is_paused = true
	start()

func start() -> void:
	Ref.world.load_room(Data.get_state("room"), Data.get_state("anchor"))
