class_name Intro extends Node2D

const WORD_POOL: Array[String] = [
	"love", "hope", "despair", "rage", "vengeance", "betrayal", "guilt",
	"desire", "hurt", "destroy", "you", "me", "animal", "beast", "creature",
	"hatred", "disgust", "envy", "woman", "man", "myself", "help",
	"kill", "passion", "joy", "mine", "heaven", "hell", "dream",
	"reason", "reality", "heart", "mind", "head", "eye", "peace",
	"war", "help", "bitter", "agony", "sin", "innocent", "dear"
]

signal finished

var velocity: Vector3 = Vector3(0, 0, 0)
var time: float = 1.0

func _ready() -> void:
	set_physics_process(false)
	%TextTimer.timeout.connect(_on_timeout)

func _on_timeout() -> void:
	var choice: String = WORD_POOL.pick_random()
	%Text.text = "[center][shake rate=3 level=6]%s[/shake][/center]" % choice
	%TextTimer.start(time)
	time = time * 0.968
	if randf() < 0.2 and not %Invert.visible :
		%MiniStaticPlayer.play()
		%Invert.visible = true
		await get_tree().create_timer(0.25).timeout
		%Invert.visible = false

func play() -> void:
	switch(1)
	
	%Cover.visible = false
	visible = true
	
	%MusicPlayer.play()
	%StaticPlayer.play()
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%MusicPlayer, "volume_db", 0, 2.0)
	tween.tween_property(%StaticPlayer, "volume_db", 9, 15.0)
	
	set_physics_process(true)
	await Ref.transition.trans_out()
	%TextTimer.start(time)
	await get_tree().create_timer(30.0).timeout
	set_physics_process(false)
	
	%Cover.visible = true
	%CrashPlayer.play()
	%TextTimer.stop()
	
	tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%MusicPlayer, "volume_db", -60, 1.0)
	tween.tween_property(%StaticPlayer, "volume_db", -60, 6.0)
	
	await %CrashPlayer.finished
	await get_tree().create_timer(4.0).timeout
	await Ref.transition.trans_in()
	
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

func _physics_process(delta: float) -> void:
	%Camera3D.global_position += velocity * delta
	velocity += Vector3(0, 0, -0.6) * delta
