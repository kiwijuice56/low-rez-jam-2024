class_name Final extends Room

func _ready() -> void:
	super._ready()
	%FinalBoss.died.connect(_on_died)

func _on_died() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%Background, "color", Color("#FFFFFF"), 3.0)
	tween.tween_property(%MusicPlayer, "volume_db", 0.0, 3.0)
	%MusicPlayer.play()
