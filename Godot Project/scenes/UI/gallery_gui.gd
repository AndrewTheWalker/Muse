extends Control

@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/CenterContainer/TextureRect
@onready var credit_label: Label = $MarginContainer/VBoxContainer/CreditLabel
@onready var button_navigate_left: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonNavigateLeft
@onready var button_back: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonBack
@onready var button_navigate_right: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonNavigateRight

var image_index : Array = []
var current_index : int = 6
var current_image

func _ready() -> void:
	load_images("res://assets/GalleryArt/")
	set_image(current_index)
	button_navigate_right.grab_focus()
	
func load_images(folder_path: String):

	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()    
		while file_name != "":

# Ensure it's a file and not a directory

			if not dir.current_is_dir():

# Filter for image extensions (e.g., .png, .jpg)
# Note: On export, Godot converts .png to .png.import or .ctex

				if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
					var full_path = folder_path + "/" + file_name     

# Use ResourceLoader to load the image as a Texture resource

					var texture = ResourceLoader.load(full_path)
					if texture:
						image_index.append(texture)         
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", folder_path)

func sort_index(step:int):
	## this line allows us to cycle through the contents of the image array and loop back to the beginning
		# if we reach the end. The idea is that we use modulo, because if the result of current_index+1 is 
		# less than image_index.size, the modulo is just the same number. But if it is equal to 
		# available targets.size, the result is 0, which is conveniently the first index entry.
		# neat!
	var new_index = (current_index+step) % image_index.size()
	current_index = new_index
	set_image(new_index)
	set_credits(new_index)

func set_credits(idx:int):
	print("credits index ",idx)
	match idx:
		0:
			credit_label.text = "Artist: Andrew Walker"
		1:
			credit_label.text = "Artist: Andrew Walker"
		2:
			credit_label.text = "Artist: Andrew Walker"
		3:
			credit_label.text = "Artist: Andrew Walker"
		4:
			credit_label.text = "Artist: Andrew Walker"
		5:
			credit_label.text = "Artist: Jonah Chang"
		6:
			credit_label.text = "Artist: Mitchell McLeod"
		7:
			credit_label.text = "Artist: Mitchell McLeod"
		8:
			credit_label.text = "Artist: Mitchell McLeod"
		9:
			credit_label.text = "Artist: Mitchell McLeod"
		10:
			credit_label.text = "Artist: Mitchell McLeod"
		11:
			credit_label.text = "Artist: Mitchell McLeod"
		12:
			credit_label.text = "Artist: Mitchell McLeod"


func set_image(idx:int):
	print("image index ", idx)
	texture_rect.texture = image_index[idx]


func _on_button_navigate_right_pressed() -> void:
	sort_index(1)


func _on_button_back_pressed() -> void:
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/main_menu_gui.tscn")
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/main_menu_3d.tscn")
