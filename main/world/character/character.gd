class_name Character extends Area2D

const TILE_SIZE: int = 9
const DIR_MAP: Dictionary = {"up": Vector2.UP, "right": Vector2.RIGHT, "down": Vector2.DOWN, "left": Vector2.LEFT}

@export var movement_time: float = TILE_SIZE / 60.0

var targeted_interactable: Interactable
var in_movement: bool = false
var facing_dir: Vector2

func move(dir: Vector2) -> void:
	if in_movement or Ref.world.is_paused:
		return
	
	facing_dir = dir
	
	%CollisionRays.rotation = Vector2(1, 0).angle_to(dir)
	%LeftRay.force_raycast_update()
	%RightRay.force_raycast_update()
	if %LeftRay.is_colliding() or %RightRay.is_colliding():
		return
	
	in_movement = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + dir * TILE_SIZE, movement_time)
	await tween.finished
	
	in_movement = false
