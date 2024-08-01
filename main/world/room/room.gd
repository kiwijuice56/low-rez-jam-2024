class_name Room extends Node2D

const MUSIC_TRANS: float = 0.2

func load_in() -> void:
	%MusicPlayer.volume_db = -60
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", 0.0, MUSIC_TRANS)
	await tween.finished

func load_out() -> void:
	%MusicPlayer.volume_db = 0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", -60, MUSIC_TRANS)
	await tween.finished
