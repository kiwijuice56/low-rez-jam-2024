class_name Battle extends Node2D

func _ready() -> void:
	%UI.visible = false

func battle(encounter: Encounter) -> bool:
	Ref.world.is_paused = true
	await Ref.transition.trans_in()
	
	Ref.world_textbox.exit()
	
	%UI.visible = true
	
	var player_party: Array[Fighter] = Ref.player_party.get_active_fighters()
	var enemy_party: Array[Fighter] = []
	for scene in encounter.fighters:
		var new_fighter: Fighter = scene.instantiate()
		%EnemyParty.add_child(new_fighter)
		enemy_party.append(new_fighter)
	
	await get_tree().create_timer(10.0).timeout
	
	await Ref.transition.trans_out()
	
	await Ref.transition.trans_in()
	%UI.visible = false
	await Ref.transition.trans_out()
	
	return true
