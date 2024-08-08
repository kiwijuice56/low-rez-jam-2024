class_name Room extends Node2D

const MUSIC_TRANS: float = 0.25

var old_db: float

func _ready() -> void:
	old_db =  %MusicPlayer.volume_db
	%MusicPlayer.volume_db = -60

func load_in() -> void:
	%MusicPlayer.playing = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", old_db, MUSIC_TRANS)
	await tween.finished
	
	%MusicPlayer.playing = true
	%MusicPlayer.volume_db = old_db

func load_out() -> void:
	%MusicPlayer.playing = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%MusicPlayer, "volume_db", -60, MUSIC_TRANS)
	await tween.finished
	
	%MusicPlayer.playing = true

func pause_music() -> void:
	await load_out()

func resume_music() -> void:
	await load_in()

func get_bounds() -> Rect2:
	return Rect2(%TopLeft.global_position, %BottomRight.global_position - %TopLeft.global_position)
