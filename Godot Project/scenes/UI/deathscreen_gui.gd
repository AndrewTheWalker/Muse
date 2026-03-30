extends Control

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start()



func _on_timer_timeout() -> void:
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/main_menu_gui.tscn")
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/main_menu_3d.tscn")
