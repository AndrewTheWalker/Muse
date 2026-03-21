extends Control

@onready var button_back: Button = $MarginContainer/VBoxContainer/ButtonBack



@onready var parent = $".."

func _ready() -> void:
	button_back.grab_focus()

# this is an unstable/lazy way of handling this. I ought to have a proper UI class if I were to do this properly.
# this only works because I know that the parent node is always going to be pause menu
func _on_button_back_pressed() -> void:
	hide()
	parent.button_resume.grab_focus()
	await get_tree().create_timer(0.2).timeout
	queue_free()
	
