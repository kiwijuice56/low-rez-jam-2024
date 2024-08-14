class_name FinalBoss extends Enemy

func _ready() -> void:
	super._ready()
	%Timer.timeout.connect(_on_look)

func _on_look() -> void:
	var p: Vector2 = Ref.player.global_position
	var a: Vector2 = global_position
	if p.x < a.x:
		%Sprite2D.frame = 12
		return
	if p.x > a.x:
		%Sprite2D.frame = 4
		return
	if p.y < a.y:
		%Sprite2D.frame = 8
		return
	if p.y > a.y:
		%Sprite2D.frame = 0
		return
