extends Control

@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/CenterContainer/TextureRect

@onready var image0 = preload("uid://cje6ooyfgv7l5")
@onready var image1 = preload("uid://5isvn7e7v3j1")
@onready var image2 = preload("uid://dk4acln7jmg2p")
@onready var image3 = preload("uid://6g3p32r3at8t")
@onready var image4 = preload("uid://d3fkoohjikr1q")
@onready var image5 = preload("uid://yed0nx5m6mfj")
@onready var image6 = preload("uid://c684u6lrp4lq5")
@onready var image7 = preload("uid://dl2y6ciq1c4v4")
@onready var image8 = preload("uid://dlbpja71jowwp")
@onready var image9 = preload("uid://crcme8u446dau")
@onready var image10 = preload("uid://mdhd3c0yhc57")
@onready var image11 = preload("uid://87aq03kijvq3")
@onready var image12 = preload("uid://dn7j077qvcw2q")

var index : Array = [0,1,2,3,4,5,6,7,8,9,10,11,12]

func _ready() -> void:
	texture_rect.texture = image0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_image(idx:int):
	match idx:
		0:
			texture_rect.texture = image0
		1:
			texture_rect.texture = image1
		2:
			texture_rect.texture = image2
		3:
			texture_rect.texture = image3
		4:
			texture_rect.texture = image4
		5:
			texture_rect.texture = image5
		6:
			texture_rect.texture = image6
		7:
			texture_rect.texture = image7
		8:
			texture_rect.texture = image8
		9:
			texture_rect.texture = image9
		10:
			texture_rect.texture = image10
		11:
			texture_rect.texture = image11
		12:
			texture_rect.texture = image12
