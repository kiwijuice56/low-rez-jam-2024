class_name Player extends Character

var latest_input: String 
var queue: Array[String]

func _physics_process(delta: float) -> void:
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

func play_movement_animation() -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.play(latest_input)

func play_look_animation() -> void:
	%AnimationPlayer.stop()
	%AnimationPlayer.play("look_" + latest_input)

func step() -> void:
	%StepPlayer.stop()
	%StepPlayer.play()
