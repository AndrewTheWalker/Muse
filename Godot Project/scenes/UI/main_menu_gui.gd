extends Control

@onready var button_begin: Button = $MarginContainer/VBoxContainer/ButtonBegin
@onready var button_about: Button = $MarginContainer/VBoxContainer/ButtonAbout
@onready var button_settings: Button = $MarginContainer/VBoxContainer/ButtonSettings


func _ready() -> void:
	button_begin.grab_focus()
