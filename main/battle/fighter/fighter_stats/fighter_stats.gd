class_name FighterStats extends Resource

@export var max_hp: int:
	set(val):
		max_hp = clamp(val, 0, 99)
@export var max_tp: int:
	set(val):
		max_tp = clamp(val, 0, 99)
@export var strength: int:
	set(val):
		strength = clamp(val, 0, 99)
@export var magic: int:
	set(val):
		magic = clamp(val, 0, 99)
@export var defence: int:
	set(val):
		defence = clamp(val, 0, 99)
@export var luck: int:
	set(val):
		luck = clamp(val, 0, 99)
@export var unlocked_skills: Array[int]
