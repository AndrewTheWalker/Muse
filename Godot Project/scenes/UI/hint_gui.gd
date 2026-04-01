extends Control

@onready var center_container: CenterContainer = $VBoxContainer/CenterContainer
@onready var text_label: Label = $"VBoxContainer/CenterContainer/Text Label"

var is_revealed : bool = false

func _ready() -> void:
	hide()
	SignalBus.connect("HINT_REVEAL",reveal)
	SignalBus.connect("HINT_HIDE",unreveal)

func reveal(text_to_display:String):
	show()
	var tween = create_tween()
	text_label.text = text_to_display
	tween.tween_property(center_container,"modulate",Color(1,1,1,0.8),0.1)
	is_revealed = true
	
	
func unreveal():
	var tween = create_tween()
	tween.tween_property(center_container,"modulate",Color(1,1,1,0),0.1)
	is_revealed = false
	await tween.finished
	hide()
