extends Node

@onready var main: Main = get_tree().get_root().get_node("Main")
@onready var world_textbox: TextBox = main.get_node("World/UI/MarginContainer/TextBox")
