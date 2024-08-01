class_name Menu extends Control

signal entered
signal exited(full_exit: bool)

func enter() -> void:
	visible = true
	entered.emit()

func exit(full_exit: bool = false) -> void:
	visible = false
	exited.emit(full_exit)
