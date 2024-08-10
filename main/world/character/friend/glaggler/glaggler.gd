class_name Glaggler extends Friend

@export var conversation_none: Array[Dialogue]
@export var conversation_enoch: Array[Dialogue]

func _on_interacted(interact_initiator: Character) -> void:
	if "enoch" in Data.get_state("party_order", []):
		conversation = conversation_enoch
	else:
		conversation = conversation_none
	await super._on_interacted(interact_initiator)
