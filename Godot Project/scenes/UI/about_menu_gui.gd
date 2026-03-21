extends Control

@onready var button: Button = $MarginContainer2/MarginContainer/VBoxContainer/MarginContainer/Button


func _ready() -> void:
	button.grab_focus()


func _on_button_pressed() -> void:
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/main_menu_gui.tscn")
