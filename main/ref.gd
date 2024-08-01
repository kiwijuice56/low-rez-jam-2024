extends Node

@onready var main: Main = get_tree().get_root().get_node("Main")
@onready var world: World = main.get_node("World")
@onready var player: Player = world.get_node("Player")
@onready var world_textbox: TextBox = world.get_node("UI/MarginContainer/TextBox")
