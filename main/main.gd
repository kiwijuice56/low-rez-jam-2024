class_name Main extends Node

func _ready() -> void:
	randomize()
	Ref.world.is_paused = true
	
	%TitleMenu.enter()
	await %TitleMenu.exited
	
	if Data.overload_save or not ResourceLoader.exists(Data.save_path + str(0) + "_save.tres"):
		Data.initialize()
		Ref.player_party.load_party_members()
		Data.save_state(0)
		
		%Intro.play()
		await %Intro.finished
	Data.load_state(0)
	
	start()

func start() -> void:
	Ref.world.load_room(Data.get_state("room"), Data.get_state("anchor"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("help"):
		var image: Image = get_viewport().get_texture().get_image()
		image.save_png("res://promotional/screenshot" + str(randi() % 9999) + ".png")
