extends Node
class_name GameController


@export var world_3d : Node3D
@export var gui : Control
@onready var fade_anim = $TransitionAnim/AnimationPlayer
@onready var fade_timer : Timer =$TransitionTimer

var current_3d_scene
var current_gui_scene



func _ready():
	fade_anim.play("fade_out")
	Gamestate.game_controller = self
	current_3d_scene = $World3D/MainMenu3D
	current_gui_scene = $GUI/MainMenuGUI
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Gamestate.toggle_pause()

func change_gui_scene(new_scene: String, delete : bool = true, keep_running : bool = false) -> void:
		set_process_input(false)
		fade_in()
		await fade_timer.timeout
		if current_gui_scene != null:
			if delete:
				current_gui_scene.queue_free()
			elif keep_running:
				current_gui_scene.visible = false
			else:
				gui.remove_child(current_gui_scene)
			var new = load(new_scene).instantiate()
			gui.add_child(new)
			current_gui_scene = new
		fade_out()
		set_process_input(true)

func change_3d_scene(new_scene: String, delete : bool = true, keep_running : bool = false) -> void:
		set_process_input(false)
		fade_in()
		await fade_timer.timeout
		if current_3d_scene != null:
			if delete:
				current_3d_scene.queue_free()
			elif keep_running:
				current_3d_scene.visible = false
			else:
				world_3d.remove_child(current_3d_scene)
			var new = load(new_scene).instantiate()
			world_3d.add_child(new)
			current_3d_scene = new
		fade_out()
		set_process_input(true)

func fade_in():
	fade_timer.start()
	fade_anim.play("fade_in")
	
func fade_out():
	fade_anim.play("fade_out")
