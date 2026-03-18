extends Control

@onready var button_begin: Button = $MarginContainer/VBoxContainer/ButtonBegin
@onready var button_about: Button = $MarginContainer/VBoxContainer/ButtonAbout
@onready var button_settings: Button = $MarginContainer/VBoxContainer/ButtonSettings

@onready var menu_1: AudioStreamPlayer = $Menu1
@onready var menu_3: AudioStreamPlayer = $Menu3


func _ready() -> void:
	button_begin.grab_focus()


func _on_button_settings_pressed() -> void:
	pass # Replace with function body.


func _on_button_about_pressed() -> void:
	pass # Replace with function body.


func _on_button_begin_pressed() -> void:
	menu_1.play()
	Gamestate.game_controller.change_3d_scene("res://scenes/Maps/sillymap2.tscn")
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/gameplay_ui.tscn")
	await get_tree().create_timer(1.1).timeout
	#queue_free()
