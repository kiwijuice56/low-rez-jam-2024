class_name Battle extends Node2D

const TEXT_SPEED: int = 64
const PREBATTLE_DELAY: float = 1.1
const TURN_SWAP_DELAY: float = 1.0
const POST_ACTION_DELAY: float = 0.8
const MUSIC_TRANS_TIME: float = 0.2
const TRANS_TIME: float = 0.08

var in_party_view: bool = true

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
	for fighter in player_party:
		fighter.visible = true
		fighter.battle_reset()
	
	var enemy_party: Array[Fighter] = []
	for scene in encounter.fighters:
		var new_fighter: Fighter = scene.instantiate()
		var base_name: String = new_fighter.name
		var copy_count: int = enemies_with_name(enemy_party, base_name)
		if copy_count > 0:
			base_name += "-" + "abcdefghijkl"[copy_count - 1]
		new_fighter.name = base_name
		
		%EnemyParty.add_child(new_fighter)
		enemy_party.append(new_fighter)
		new_fighter.battle_reset()
		new_fighter.visible = true
	position_fighters(player_party, enemy_party)
	%Text.display_text("a battle broke out!", TEXT_SPEED)
	
	await party_view(player_party[0], player_party)
	
	await Ref.transition.trans_out()
	
	await get_tree().create_timer(PREBATTLE_DELAY).timeout
	
	### BATTLE LOOP ###
	
	var player_turn: bool = true
	
	while true:
		if len(get_alive_fighters(player_party)) == 0 or len(get_alive_fighters(enemy_party)) == 0:
			break
		var current_party: Array[Fighter] = player_party if player_turn else enemy_party
		var idx: int = 0
		var full_turns: int = len(get_alive_fighters(current_party))
		var half_turns: int = 0
		%PressTurnWidget.initialize(full_turns, player_turn)
		await get_tree().create_timer(TURN_SWAP_DELAY).timeout
		while full_turns + half_turns > 0:
			if len(get_alive_fighters(player_party)) == 0 or len(get_alive_fighters(enemy_party)) == 0:
				break
			var fighter: Fighter = current_party[idx]
			idx = (idx + 1) % len(current_party)
			if fighter.dead:
				continue
			
			var stunned: bool = fighter.get_node("%Effects").get_node("Stun").active
			var turns_used: Action.TurnUsage
			
			if not stunned:
				var choice: Dictionary
				if player_turn:
					choice = await get_player_choice(fighter, player_party, enemy_party)
				else:
					choice = await fighter.get_choice(enemy_party, player_party)
				
				fighter.start_turn()
				turns_used = await choice.action.act(fighter, choice.targets)
			else:
				%Text.display_text("%s is stunned..." % fighter.name, TEXT_SPEED) 
				await get_tree().create_timer(1.0).timeout
				turns_used = Action.TurnUsage.NORMAL
			
			if turns_used == Action.TurnUsage.NORMAL:
				if half_turns > 0:
					half_turns -= 1
				else:
					full_turns -= 1
				await %PressTurnWidget.waste_turns(1)
			if turns_used == Action.TurnUsage.ADVANTAGE:
				if full_turns > 0:
					%GainTurnPlayer.play()
					full_turns -= 1
					half_turns += 1
					await %PressTurnWidget.flash_turn()
				else:
					await %PressTurnWidget.waste_turns(1)
					half_turns -= 1
			if turns_used == Action.TurnUsage.WASTE:
				%WasteTurnPlayer.play()
				await %PressTurnWidget.waste_turns(min(2, full_turns))
				for _i in range(2):
					if half_turns > 0:
						half_turns -= 1
					else:
						full_turns -= 1
			await fighter.after_turn()
			await get_tree().create_timer(POST_ACTION_DELAY).timeout
		%Text.display_text(" ", TEXT_SPEED)
		player_turn = not player_turn

	### BATTLE LOOP END ###
	
	stop_music()
	%Text.display_text("   ", TEXT_SPEED)
	await get_tree().create_timer(1.0).timeout
	
	var lose: bool = len(get_alive_fighters(player_party)) == 0
	if lose:
		await Ref.game_over.game_over()
	else:
		# level up stuffs
		%LevelSubmenu.mode = "level up"
		await %LevelSubmenu.enter()
		var levels: int = await %LevelSubmenu.battle_end_sequence(encounter.xp_drop)
		await %LevelSubmenu.exit()
		
		await %StatusSubmenu.display_level_ups(levels)
		# await %StatusSubmenu.exit()
		
		await Ref.transition.trans_in()
	
	# cleanup stuffs
	for fighter in player_party:
		fighter.visible = false
	%UI.visible = false
	%FighterLayer.visible = false
	Ref.world.loaded_room.resume_music()
	
	if lose:
		Ref.world.load_room("hell_fall", "Default", false)
	else:
		await Ref.transition.trans_out()
	
	return not lose

func enemies_with_name(enemy_party: Array[Fighter], base_name: String) -> int:
	var count: int = 0
	for child in enemy_party:
		if child.name.begins_with(base_name):
			count += 1
	return count

func get_player_choice(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
	var stack: Array[Dictionary] = [{"level": "outer", "idx": 0}]
	while len(stack) > 0:
		var node: Dictionary = stack.pop_back()
		match node.level:
			"outer":
				Ref.battle_text.display_text("what will %s do?" % fighter.name, TEXT_SPEED)
				_initialize_outer(fighter, player_party, enemy_party, node.idx)
				if not %ChoiceMenu.mini_visible:
					await %ChoiceMenu.mini_trans_in()
				if in_party_view:
					await menu_view(fighter, player_party)
				
				var choice: Dictionary = await _get_outer_choice()
				
				if "action" in choice and choice.action.name.to_lower() == "pass":
					await party_view(fighter, player_party)
					var empty: Array[Fighter] = []
					return {"action": choice.action, "targets": empty}
				
				stack.append({"level": "outer", "idx": choice.idx})
				
				if "submenu" in choice:
					await %ChoiceMenu.mini_trans_out()
					stack.append({"level": choice.submenu, "idx": 0})
				else:
					stack.append({"level": "target", "action": choice.action})
			"target":
				Ref.battle_text.display_text("%s who?" % node.action.verb, TEXT_SPEED)
				if not in_party_view:
					await party_view(fighter, player_party)
				var targets: Array[Fighter] = await _get_targets(node.action, fighter, player_party, enemy_party) 
				if len(targets) == 0:
					continue
				return {"action": node.action, "targets": targets}
			"skills":
				_initialize_skills(fighter, player_party, enemy_party, node.idx)
				if not %ChoiceMenu.mini_visible:
					await %ChoiceMenu.mini_trans_in()
				if in_party_view:
					await menu_view(fighter, player_party)
				
				var choice: Dictionary = await _get_action_choice()
				
				if not choice.action:
					await %ChoiceMenu.mini_trans_out()
					continue
				stack.append({"level": "skills", "idx": choice.idx})
				stack.append({"level": "target", "action": choice.action})
			"items":
				_initialize_items(fighter, player_party, enemy_party, node.idx)
				if not %ChoiceMenu.mini_visible:
					await %ChoiceMenu.mini_trans_in()
				if in_party_view:
					await menu_view(fighter, player_party)
				
				var choice: Dictionary = await _get_action_choice()
				
				if not choice.action:
					await %ChoiceMenu.mini_trans_out()
					continue
				stack.append({"level": "items", "idx": choice.idx})
				stack.append({"level": "target", "action": choice.action})
	
	return {}

func _get_targets(action: Action, _fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Array[Fighter]:
	var pool: Array[Fighter] = action.get_available_targets(player_party, enemy_party)
	
	if action.target_amount == "Single":
		var target: Array[Fighter] = await %TargetSelecter.select_single_target(pool)
		return target
	else:
		var empty: Array[Fighter] = []
		return pool if await %TargetSelecter.select_all_targets(pool) else empty

func _get_outer_choice() -> Dictionary:
	var button: ChoiceButton = await %ChoiceMenu.get_choice()
	if button.action:
		return {"action": button.action, "idx": button.idx}
	else:
		return {"submenu": button.action_name, "idx": button.idx}

func _get_action_choice() -> Dictionary:
	var button: ChoiceButton = await %ChoiceMenu.get_choice()
	if button and button.action:
		return {"action": button.action, "idx": button.idx}
	else:
		return {"action": null}

func _initialize_outer(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], initial_idx: int) -> void:
	var skill_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	skill_button.initialize_other("skills", preload("res://main/battle/action/icons/icon_skill.png"))
	var item_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	item_button.initialize_other("items", preload("res://main/battle/action/icons/icon_item.png"))
	var attack_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	attack_button.initialize(fighter.base_attack, player_party, enemy_party)
	var pass_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	pass_button.initialize(fighter.base_pass, player_party, enemy_party)
	
	var buttons: Array[ChoiceButton] = [attack_button, skill_button, item_button, pass_button]
	%ChoiceMenu.initialize(initial_idx, false, buttons)

func _initialize_items(_fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], initial_idx: int) -> void:
	var buttons: Array[ChoiceButton] = []
	for skill in %ItemActions.get_children():
		var new_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
		new_button.initialize(skill, player_party, enemy_party, true)
		buttons.append(new_button)
	var back_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	back_button.initialize_other("back", preload("res://main/battle/action/icons/icon_pass.png"))
	back_button.description = "go back"
	buttons.append(back_button)
	%ChoiceMenu.initialize(initial_idx, true, buttons)

func _initialize_skills(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], initial_idx: int) -> void:
	var buttons: Array[ChoiceButton] = []
	for skill in fighter.get_node("%Skills").get_children():
		if skill.get_index() not in fighter.stats.unlocked_skills:
			continue
		
		var new_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
		new_button.initialize(skill, player_party, enemy_party)
		buttons.append(new_button)
	var back_button: ChoiceButton = %ChoiceMenu.choice_button_scene.instantiate()
	back_button.initialize_other("back", preload("res://main/battle/action/icons/icon_pass.png"))
	back_button.description = "go back"
	buttons.append(back_button)
	%ChoiceMenu.initialize(initial_idx, true, buttons)

func party_view(fighter: Fighter, player_party: Array[Fighter]) -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	
	%ChoiceMenu.position.y = 0
	tween.tween_property(%ChoiceMenu, "position:y", 25, TRANS_TIME)
	
	fighter.global_position = %MenuFighterPosition.global_position 
	tween.tween_property(fighter, "global_position:y", %MenuFighterPosition.global_position.y + 30, TRANS_TIME)
	
	await tween.finished
	
	tween = get_tree().create_tween().set_parallel(true)
	
	position_players(player_party, Vector2(0, 30))
	for member in player_party:
		tween.tween_property(member, "global_position:y", member.global_position.y - 30, TRANS_TIME)
	
	await tween.finished
	
	in_party_view = true

func menu_view(fighter: Fighter, player_party: Array[Fighter]) -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	position_players(player_party, Vector2())
	for member in player_party:
		tween.tween_property(member, "global_position:y", member.global_position.y + 30, TRANS_TIME)
	
	await tween.finished
	
	tween = get_tree().create_tween().set_parallel(true)
	
	%ChoiceMenu.position.y = 25
	tween.tween_property(%ChoiceMenu, "position:y", 0, TRANS_TIME)
	
	fighter.global_position = %MenuFighterPosition.global_position + Vector2(0, 30)
	tween.tween_property(fighter, "global_position:y", %MenuFighterPosition.global_position.y, TRANS_TIME)
	
	await tween.finished
	
	in_party_view = false
	

func get_alive_fighters(pool: Array[Fighter]) -> Array[Fighter]:
	var alive: Array[Fighter] = []
	for fighter in pool:
		if not fighter.dead:
			alive.append(fighter)
	return alive

func position_players(player_party: Array[Fighter], offset: Vector2) -> void:
	for i in range(len(player_party)):
		player_party[i].global_position = offset + %PlayerPositions.get_child(len(player_party) - 1).get_child(i).global_position

func position_fighters(player_party: Array[Fighter], enemy_party: Array[Fighter]) -> void:
	position_players(player_party, Vector2())
	for i in range(len(enemy_party)):
		enemy_party[i].global_position = %EnemyPositions.get_child(len(enemy_party) - 1).get_child(i).global_position

func stop_music() -> void:
	%BattleMusicPlayer.volume_db = 0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%BattleMusicPlayer, "volume_db", -60, MUSIC_TRANS_TIME * 8)
	await tween.finished

func start_music(stream: AudioStream) -> void:
	%BattleMusicPlayer.stream = stream
	%BattleMusicPlayer.volume_db = -60
	%BattleMusicPlayer.playing = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%BattleMusicPlayer, "volume_db", 0.0, MUSIC_TRANS_TIME)
	await tween.finished
