class_name BubblebearFriend extends Friend

@export var conversation_sick: Array[Dialogue]
@export var conversation_happy: Array[Dialogue]

func _ready() -> void:
	super._ready()
	conversation = conversation_sick
	await get_parent().ready
	%Button.pressed.connect(_on_pressed)
	if Data.get_state(%Button.key, false):
		_on_pressed()

func _on_pressed():
	conversation = conversation_happy
