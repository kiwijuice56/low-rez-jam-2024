class_name Battle extends Node2D

const TEXT_SPEED: int = 64
const PREBATTLE_DELAY: float = 2.0
const POST_ACTION_DELAY: float = 1.0
const MUSIC_TRANS_TIME: float = 0.2

func _ready() -> void:
	%UI.visible = false
	%FighterLayer.visible = false

func battle(encounter: Encounter) -> bool:
	Ref.world.is_paused = true
	
	await Ref.transition.trans_in()
	
	start_music(encounter.music)
	Ref.world.loaded_room.pause_music()
	Ref.world_textbox.exit()
	
	if %BackgroundHolder.get_child_count() > 0:
		%BackgroundHolder.get_child(0).queue_free()
	%BackgroundHolder.add_child(encounter.background.instantiate())
	
	%UI.visible = true
	%FighterLayer.visible = true
	
	var player_party: Array[Fighter] = Ref.player_party.get_active_fighters()
	var enemy_party: Array[Fighter] = []
	for scene in encounter.fighters:
		var new_fighter: Fighter = scene.instantiate()
		%EnemyParty.add_child(new_fighter)
		enemy_party.append(new_fighter)
	position_fighters(player_party, enemy_party)
	%Text.display_text("a battle broke out!", TEXT_SPEED)
	
	await Ref.transition.trans_out()
	
	await get_tree().create_timer(PREBATTLE_DELAY).timeout
	
	### BATTLE LOOP ###
	
	var player_turn: bool = false
	var current_party: Array[Fighter] = player_party if player_turn else enemy_party
	while true:
		if len(get_alive_fighters(player_party)) == 0 or len(get_alive_fighters(enemy_party)) == 0:
			break
		var idx: int = 0
		var full_turns: int = len(get_alive_fighters(current_party)) * 2
		var half_turns: int = 0
		while full_turns + half_turns > 0:
			var fighter: Fighter = current_party[idx]
			idx = (idx + 1) % len(current_party)
			if fighter.dead:
				continue
			
			var choice: Dictionary
			if player_party:
				choice = await get_player_choice(fighter, player_party, enemy_party)
			else:
				choice = await fighter.get_choice(enemy_party, player_party)
			
			var turns_used: Action.TurnUsage = choice.action.act(choice.targets)
			if turns_used == Action.TurnUsage.NORMAL:
				if half_turns > 0:
					half_turns -= 1
				else:
					full_turns -= 1
			if turns_used == Action.TurnUsage.ADVANTAGE:
				if full_turns > 0:
					full_turns -= 1
					half_turns += 1
				else:
					half_turns -= 1
			if turns_used == Action.TurnUsage.WASTE:
				for _i in range(2):
					if half_turns > 0:
						half_turns -= 1
					else:
						full_turns -= 1
			await get_tree().create_timer(POST_ACTION_DELAY).timeout

	### BATTLE LOOP END ###
	
	await Ref.transition.trans_in()
	%UI.visible = false
	%FighterLayer.visible = false
	Ref.world.loaded_room.resume_music()
	stop_music()
	await Ref.transition.trans_out()
	
	return true

func get_player_choice(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
	var stack: Array[Dictionary] = [{"level": "outer", "idx": 0}]
	while len(stack) > 0:
		var node: Dictionary = stack.pop_back()
		match node.level:
			"outer":
				# [ initialize menu buttons here ] #
				await menu_view()
				
				var choice: Dictionary = await _get_outer_choice(fighter, player_party, enemy_party, node["idx"])
				
				
				if "pass" in choice:
					await party_view()
					return {"action": choice.action, "targets": []}
				
				stack.append({"level": "outer", "idx": choice.idx})
				
				if "submenu" in choice:
					stack.append({"level": choice.submenu, "idx": 0})
				else:
					stack.append({"level": "target", "action": choice.action})
			"target":
				await party_view()
				var targets: Array[Fighter] = _get_targets(node.action, fighter, player_party, enemy_party) 
				if len(targets) == 0:
					continue
			"skill":
				# [ initialize menu buttons here ] #
				var choice: Dictionary = await _get_skill_choice(fighter, player_party, enemy_party, node["idx"])
				
				if not choice.action:
					continue
				stack.append({"level": "skill", "idx": choice.idx})
				stack.append({"level": "target", "action": choice.action})
			"item":
				# [ initialize menu buttons here ] #
				var choice: Dictionary = await _get_skill_choice(fighter, player_party, enemy_party, node["idx"])
				
				if not choice.action:
					continue
				stack.append({"level": "item", "idx": choice.idx})
				stack.append({"level": "target", "action": choice.action})
	
	return {}

func party_view() -> void:
	pass

func menu_view() -> void:
	pass

func _get_targets(action: Action, fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Array[Fighter]:
	return []

func _get_outer_choice(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], initial_idx: int) -> Dictionary:
	return {"action": null, "submenu": "skill", "pass": true, "idx": 0}

func _get_skill_choice(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], initial_idx: int) -> Dictionary:
	return {"action": null, "idx": 0}

func _get_item_choice(initial_idx: int, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
	return {"action": null, "idx": 0}

func get_alive_fighters(pool: Array[Fighter]) -> Array[Fighter]:
	var alive: Array[Fighter] = []
	for fighter in pool:
		if not fighter.dead:
			alive.append(fighter)
	return alive

func position_fighters(player_party: Array[Fighter], enemy_party: Array[Fighter]) -> void:
	for i in range(len(player_party)):
		player_party[i].global_position = %PlayerPositions.get_child(len(player_party) - 1).get_child(i).global_position
	for i in range(len(enemy_party)):
		enemy_party[i].global_position = %EnemyPositions.get_child(len(enemy_party) - 1).get_child(i).global_position

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
