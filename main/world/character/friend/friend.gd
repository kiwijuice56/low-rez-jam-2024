class_name Friend extends Character

func _ready() -> void:
	%Interactable.interacted.connect(_on_interacted)

func _on_interacted(interact_initiator: Character) -> void:
	interact_initiator.is_paused = true
	print("hi!")
	interact_initiator.is_paused = false
