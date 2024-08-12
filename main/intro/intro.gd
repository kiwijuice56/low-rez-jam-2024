class_name Intro extends Node2D

signal finished

func play() -> void:
	Ref.transition.trans_out()
	switch(0)
	await get_tree().create_timer(1.0).timeout
	switch(1)
	await get_tree().create_timer(1.0).timeout
	switch(0)
	await get_tree().create_timer(1.0).timeout
	switch(1)
	await get_tree().create_timer(1.0).timeout
	switch(0)
	await get_tree().create_timer(1.0).timeout
	switch(1)
	await get_tree().create_timer(1.0).timeout
	switch(0)
	await get_tree().create_timer(1.0).timeout
	switch(1)
	await get_tree().create_timer(1.0).timeout
	switch(0)
	await get_tree().create_timer(1.0).timeout

func switch(mode: int) -> void:
	if mode == 0:
		%StaticPlayer.stream_paused = true
		%Earth.visible = true
		%Fractal.visible = false
	else:
		%StaticPlayer.stream_paused = false
		%Earth.visible = false
		%Fractal.visible = true
