class_name Player extends Character

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
	var latest_input: String = queue[0]
	move(DIR_MAP[latest_input])
