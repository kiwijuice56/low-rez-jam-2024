class_name PressTurn extends Sprite2D

@export var player_texture: Texture
@export var enemy_texture: Texture

func initialize(player: bool) -> void:
	texture = player_texture if player else enemy_texture
	%MainAnimationPlayer.play("create")

func start_flashing() -> void:
	%FlashParticles.emitting = true
	%MainAnimationPlayer.play("flash")

func waste() -> void:
	%MainAnimationPlayer.play("waste")
	await %MainAnimationPlayer.animation_finished
	queue_free()
