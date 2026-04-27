extends Control

@onready var center_container: CenterContainer = $VBoxContainer/CenterContainer
@onready var text_label: Label = $"VBoxContainer/CenterContainer/HBoxContainer/Text Label"
@onready var texture_rect: TextureRect = $VBoxContainer/CenterContainer/HBoxContainer/TextureRect

const ICON_FACEBUTTON_BOTTOM = preload("uid://53vnbx078b37")
const ICON_FACEBUTTON_LEFT = preload("uid://c5pdbje7c3ulg")
const ICON_FACEBUTTON_RIGHT = preload("uid://igcv72hjsdsg")
const ICON_FACEBUTTON_TOP = preload("uid://7os42w4l5bj8")


var is_revealed : bool = false

func _ready() -> void:
	hide()
	SignalBus.connect("HINT_REVEAL",reveal)
	SignalBus.connect("HINT_HIDE",unreveal)

func reveal(text_to_display:String,icon_to_display:String):
	show()
	var tween = create_tween()
	text_label.text = text_to_display
	match icon_to_display:
		"none": texture_rect.texture = null
		"bottom": texture_rect.texture = ICON_FACEBUTTON_BOTTOM
		"left": texture_rect.texture = ICON_FACEBUTTON_LEFT
		"right": texture_rect.texture = ICON_FACEBUTTON_RIGHT
		"top": texture_rect.texture = ICON_FACEBUTTON_TOP
	tween.tween_property(center_container,"modulate",Color(1,1,1,0.8),0.1)
	is_revealed = true
	
	
func unreveal():
	var tween = create_tween()
	tween.tween_property(center_container,"modulate",Color(1,1,1,0),0.1)
	is_revealed = false
	await tween.finished
	hide()
