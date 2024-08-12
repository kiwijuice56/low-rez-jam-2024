class_name Main extends Node

func _ready() -> void:
	randomize()
	Ref.world.is_paused = true
	start()

func start() -> void:
	Ref.world.load_room(Data.get_state("room"), Data.get_state("anchor"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("help"):
		var image: Image = get_viewport().get_texture().get_image()
		image.save_png("res://promotional/screenshot" + str(randi() % 9999) + ".png")
