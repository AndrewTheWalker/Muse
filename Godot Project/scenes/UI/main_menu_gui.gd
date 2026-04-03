extends Control


@onready var button_begin: Button = $HBoxContainer/VBoxContainer/ButtonBegin
@onready var button_about: Button = $HBoxContainer/VBoxContainer/ButtonAbout
@onready var button_gallery: Button = $HBoxContainer/VBoxContainer/ButtonGallery

@onready var menu_1: AudioStreamPlayer = $Menu1
@onready var menu_3: AudioStreamPlayer = $Menu3



func _ready() -> void:
	button_begin.grab_focus()




func _on_button_about_pressed() -> void:
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/about_menu_gui.tscn")

func _on_button_begin_pressed() -> void:
	menu_1.play()
	Gamestate.game_controller.change_3d_scene("res://scenes/Maps/dungeon.tscn")
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/gameplay_ui.tscn")
	await get_tree().create_timer(1.1).timeout
	queue_free()

func _on_button_gallery_pressed() -> void:
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/gallery_gui.tscn")
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/null_3d.tscn")
