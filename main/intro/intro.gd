class_name Intro extends Node2D

signal finished

func play() -> void:
	visible = true
	switch(0)
	%MusicPlayer.play()
	%StaticPlayer.play()
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%MusicPlayer, "volume_db", 0, 2.0)
	tween.tween_property(%StaticPlayer, "volume_db", -2, 2.0)
	
	await Ref.transition.trans_out()
	
	for i in range(4.0):
		switch(0)
		await get_tree().create_timer(1.0).timeout
		switch(1)
		await get_tree().create_timer(1.0).timeout
	
	await Ref.transition.trans_in()
	
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%MusicPlayer, "volume_db", -60, 2.0)
	tween.tween_property(%StaticPlayer, "volume_db", -60, 2.0)
	
	visible = false
	finished.emit()

func switch(mode: int) -> void:
	if mode == 0:
		%StaticPlayer.stream_paused = true
		%Earth.visible = true
		%Fractal.visible = false
	else:
		%StaticPlayer.stream_paused = false
		%Earth.visible = false
		%Fractal.visible = true
