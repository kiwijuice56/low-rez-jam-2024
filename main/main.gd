class_name Main extends Node

func _ready() -> void:
	randomize()
	Ref.world.is_paused = true
	
	%TitleMenu.enter()
	var new_game: bool = await %TitleMenu.choice_made
	await Ref.transition.trans_in()
	%TitleMenu.exit()
	await get_tree().create_timer(1.0).timeout
	
	if new_game:
		Data.new_game()
		%Intro.play()
		await %Intro.finished
	else:
		Data.continue_game()
	
	start()

func start() -> void:
	Ref.world.load_room(Data.get_state("room"), Data.get_state("anchor"), false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("help"):
		var image: Image = get_viewport().get_texture().get_image()
		image.save_png("res://promotional/screenshot" + str(randi() % 9999) + ".png")
