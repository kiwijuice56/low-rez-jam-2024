class_name AnimatedTextLabel extends RichTextLabel

const DEFAULT_CHARS_PER_SECOND: int = 48
const PAUSE_LENGTH: float = 16
const SPEED_UP_MULT: float = 2.5

var character_progress: float
var characters_advanced: int
var pause_progress: float

var message_text: String = ""
var chars_per_second: float = 0.0
var pause_indices: Dictionary = {}
var is_progressing: bool = false
var is_pausing: bool = false
var is_sped_up: bool = false

var choice_idx: int = 0
var choice_length: int = -1

signal finished_progressing
signal char_advanced

func _physics_process(delta: float) -> void:
	is_sped_up = Input.is_action_pressed("cancel")
	if is_pausing:
		pause_progress -= chars_per_second * (SPEED_UP_MULT if is_sped_up else 1.0) * delta
		if pause_progress <= 0:
			is_pausing = false
	elif is_progressing:
		character_progress += chars_per_second * (SPEED_UP_MULT if is_sped_up else 1.0) * delta 
		
		if not int(character_progress) == characters_advanced:
			visible_characters = int(character_progress)
			var idx: int = int(character_progress)
			if idx in pause_indices and pause_indices[idx] > 0:
				is_pausing = true
				pause_progress = PAUSE_LENGTH
				pause_indices[idx] -= 1
				return
			
			characters_advanced = int(character_progress)
			char_advanced.emit()
		
		if characters_advanced >= len(message_text):
			finished_progressing.emit()

func display_text(new_text: String, new_chars_per_second: int = DEFAULT_CHARS_PER_SECOND) -> void:
	chars_per_second = new_chars_per_second
	text = new_text
	
	pause_indices = {}
	var bb_free_text: String = get_parsed_text()
	var pause_count: int = 0
	for i in range(len(bb_free_text)):
		if bb_free_text[i] == '_':
			var real_index: int = i - pause_count
			if real_index in pause_indices:
				pause_indices[real_index] += 1
			else:
				pause_indices[real_index] = 1
			pause_count += 1
	message_text = ''.join(bb_free_text.split('_'))
	text = ''.join(new_text.split('_'))
	
	visible_characters = 0
	characters_advanced = 0
	character_progress = 0
	
	is_progressing = true
	await finished_progressing
	is_progressing = false
