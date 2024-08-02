class_name Battle extends Node2D

const MUSIC_TRANS_TIME: float = 0.2

func _ready() -> void:
	%UI.visible = false

func battle(encounter: Encounter) -> bool:
	Ref.world.is_paused = true
	await Ref.transition.trans_in()
	start_music(encounter.music)
	Ref.world.loaded_room.pause_music()
	Ref.world_textbox.exit()
	
	%UI.visible = true
	
	var player_party: Array[Fighter] = Ref.player_party.get_active_fighters()
	var enemy_party: Array[Fighter] = []
	for scene in encounter.fighters:
		var new_fighter: Fighter = scene.instantiate()
		%EnemyParty.add_child(new_fighter)
		enemy_party.append(new_fighter)
	
	await Ref.transition.trans_out()
	
	await get_tree().create_timer(10.0).timeout
	
	await Ref.transition.trans_in()
	%UI.visible = false
	Ref.world.loaded_room.resume_music()
	stop_music()
	await Ref.transition.trans_out()
	
	return true

func stop_music() -> void:
	%BattleMusicPlayer.volume_db = 0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%BattleMusicPlayer, "volume_db", -60, MUSIC_TRANS_TIME)
	await tween.finished

func start_music(stream: AudioStream) -> void:
	%BattleMusicPlayer.stream = stream
	%BattleMusicPlayer.volume_db = -60
	%BattleMusicPlayer.playing = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%BattleMusicPlayer, "volume_db", 0.0, MUSIC_TRANS_TIME)
	await tween.finished
