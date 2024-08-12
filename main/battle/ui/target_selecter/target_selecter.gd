class_name TargetSelecter extends Node2D

@export var offset: Vector2
@export var target_icon: PackedScene

var fighter_pool: Array[Fighter]
var single_target: Sprite2D
var idx: int = 0

signal advanced(cancel: bool)

func _ready() -> void:
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if is_instance_valid(single_target):
		var old_idx: int = idx
		if event.is_action_pressed("left", false):
			%SelectPlayer.play()
			idx -= 1
		if event.is_action_pressed("right", false):
			%SelectPlayer.play()
			idx += 1
		idx = (idx + len(fighter_pool)) % len(fighter_pool)
		if idx != old_idx:
			retarget(single_target, fighter_pool[idx], fighter_pool[old_idx])
	if event.is_action_pressed("accept", false):
		%AcceptPlayer.play()
		advanced.emit(true)
	if event.is_action_pressed("cancel", false):
		%CancelPlayer.play()
		advanced.emit(false)

func select_single_target(pool: Array[Fighter]) -> Array[Fighter]:
	idx = 0
	fighter_pool = pool
	
	var new_target: Sprite2D = target_icon.instantiate()
	add_child(new_target)
	single_target = new_target
	
	retarget(new_target, fighter_pool[0], null)
	
	set_process_input(true)
	
	var accepted: bool = await advanced
	
	for fighter in fighter_pool:
		fighter.get_node("%FlashAnimationPlayer").stop()
		fighter.get_node("%FlashAnimationPlayer").play("RESET")
	
	set_process_input(false)
	
	single_target.queue_free()
	
	var fighters: Array[Fighter] = []
	if accepted:
		fighters.append(fighter_pool[idx])
	return fighters

func select_all_targets(pool: Array[Fighter]) -> Array[Fighter]:
	fighter_pool = pool
	
	var targets: Array[Sprite2D] = []
	
	for fighter in fighter_pool:
		var new_target: Sprite2D = target_icon.instantiate()
		add_child(new_target)
		retarget(new_target, fighter, null)
		targets.append(new_target)
	
	set_process_input(true)
	
	var accepted: bool = await advanced
	
	for fighter in fighter_pool:
		fighter.get_node("%FlashAnimationPlayer").stop()
		fighter.get_node("%FlashAnimationPlayer").play("RESET")
	
	for target in targets:
		target.queue_free()
	
	set_process_input(false)
	
	var empty: Array[Fighter] = []
	
	return pool if accepted else empty

func retarget(target: Sprite2D, fighter: Fighter, old_fighter: Fighter) -> void:
	if is_instance_valid(old_fighter):
		old_fighter.get_node("%FlashAnimationPlayer").stop()
		old_fighter.get_node("%FlashAnimationPlayer").play("RESET")
	fighter.get_node("%FlashAnimationPlayer").play("flash")
	target.get_node("%AnimationPlayer").stop()
	target.get_node("%AnimationPlayer").play("flash")
	target.global_position = fighter.get_node("%Center").global_position + offset
