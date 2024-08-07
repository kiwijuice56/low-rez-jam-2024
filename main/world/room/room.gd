class_name Room extends Node2D

const MUSIC_TRANS: float = 0.2

@onready var old_db: float = %MusicPlayer.volume_db

func load_in() -> void:
	%MusicPlayer.volume_db = -60
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", old_db, MUSIC_TRANS)
	await tween.finished

func load_out() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", -60, MUSIC_TRANS)
	await tween.finished

func pause_music() -> void:
	await load_out()
	%MusicPlayer.stop()

func resume_music() -> void:
	await load_in()
	%MusicPlayer.play()

func get_bounds() -> Rect2:
	return Rect2(%TopLeft.global_position, %BottomRight.global_position - %TopLeft.global_position)
