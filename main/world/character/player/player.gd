class_name Player extends Character

@export var footstep_sound_index: Array[AudioStream]
@export var volume_offset: Array[float] = [-11, -12, -13]

var latest_input: String 
var queue: Array[String]

func _physics_process(_delta: float) -> void:
	for input in DIR_MAP:
		if Input.is_action_pressed(input):
			if input in queue:
				continue
			else:
				queue.insert(0, input)
		elif input in queue:
			queue.remove_at(queue.find(input))
	
	if len(queue) == 0:
		return
	latest_input = queue[0]
	move(DIR_MAP[latest_input])

func _input(event: InputEvent) -> void:
	if not Ref.world.is_paused and not in_movement and event.is_action_pressed("menu", false):
		Ref.pause_menu.enter()

func play_movement_animation() -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.play(latest_input)

func play_look_animation() -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.play("look_" + latest_input)

func step() -> void:
	var tiles: TileMapLayer = Ref.world.loaded_room.get_node("%FootstepLayer")
	var data: TileData = tiles.get_cell_tile_data(global_position / Vector2(9, 9))
	var stream: AudioStream = footstep_sound_index[0]
	var volume: float = volume_offset[0]
	if data:
		stream = footstep_sound_index[data.get_custom_data("floor_type")]
		volume = volume_offset[data.get_custom_data("floor_type")]
	%StepPlayer.volume_db = volume
	%StepPlayer.stream = stream
	%StepPlayer.stop()
	%StepPlayer.play()

func set_limit(rect: Rect2) -> void:
	%Camera2D.limit_left = rect.position.x
	%Camera2D.limit_right = rect.position.x + rect.size.x
	%Camera2D.limit_top = rect.position.y
	%Camera2D.limit_bottom = rect.position.y + rect.size.y
