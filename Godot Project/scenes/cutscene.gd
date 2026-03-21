extends Node3D
class_name Cutscene

'''NOTE TO SELF
This is like, the absolute most thrown together solution for this, do yourself a favour and figure out a better way'''


@onready var dummy_kor: CharacterBody3D = $DummyKor
@onready var cutscene_cam_1: Camera3D = $CutsceneCam1
@onready var cutscene_cam_2: Camera3D = $CutsceneCam2
@onready var cutscene_cam_3: Camera3D = $CutsceneCam3

@onready var end_card: Control = $EndCard

@onready var door: Node3D = $Door
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	end_card.hide()
	dummy_kor.play_idle()
	door.stay_open()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DebugHurt"):
		play_cutscene()

func play_cutscene():
	cutscene_cam_1.make_current()
	animation_player.play("EndingCutscene")
	
func set_camera_2():
	cutscene_cam_2.make_current()
	
func set_camera_3():
	cutscene_cam_3.make_current()

func kor_play_idle():
	dummy_kor.play_idle()
	
func kor_play_walk():
	dummy_kor.play_walk()

func door_close():
	door.close_door()

func door_open():
	door.open_door()

func reset():
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/main_menu_3d.tscn")
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/main_menu_gui.tscn")
	
	
	
