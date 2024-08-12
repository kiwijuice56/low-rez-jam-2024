extends Node

@onready var main: Main = get_tree().get_root().get_node("Main")
@onready var world: World = main.get_node("World")
@onready var world_textbox: TextBox = world.get_node("UI/TextboxLayer/TextCanvasGroup/TextBox")
@onready var pause_menu: PauseMenu = world.get_node("UI/MarginContainer/PauseMenuCanvasGroup/PauseMenu")
@onready var shop_menu: ShopMenu = world.get_node("UI/MarginContainer/ShopMenu")
@onready var player: Player = world.get_node("Player")
@onready var transition: Transition = main.get_node("Transition")

@onready var battle: Battle = main.get_node("Battle")
@onready var battle_text: AnimatedTextLabel = battle.get_node("%UI/Text")
@onready var player_party: PlayerParty = battle.get_node("FighterLayer/PlayerParty")
@onready var battle_animation_background: Node2D = battle.get_node("%BackgroundAnimationHolder")
@onready var battle_animation_foreground: Node2D = battle.get_node("%ForegroundAnimationHolder")

@onready var game_over: GameOver = main.get_node("GameOver")
@onready var title: TitleMenu = main.get_node("%TitleMenu")
