class_name Dialogue extends Resource

@export var speaker: Speaker
@export_multiline var text: String
@export_enum("Fast", "Normal", "Slow") var speed: String = "Normal"
@export var sfx: AudioStream
@export var volume_db: float = 0.0
