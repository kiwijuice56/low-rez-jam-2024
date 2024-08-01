class_name Dialogue extends Resource

@export var speaker: String
@export var text: String
@export_enum("Default") var voice: String = "Default"
@export_enum("Fast", "Normal", "Slow") var speed: String = "Normal"
