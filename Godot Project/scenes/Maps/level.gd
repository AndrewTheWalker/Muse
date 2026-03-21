extends Node3D
class_name LevelManager

@export var player : PlayerKor
@export var cutscene : Cutscene
@onready var ending_area_3d: Area3D = $EndingArea3D

@onready var door: Node3D = $LevelGeo/Door
@onready var doorcam: Camera3D = $LevelGeo/Door/Doorcam

var num_drones_killed : int = 0
@export var drones_required : int

func _ready() -> void:
	ending_area_3d.monitoring = false
	cutscene.hide()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		set_process_input(false)
		Gamestate.game_controller.change_gui_scene("res://scenes/UI/null_gui.tscn")
		await get_tree().create_timer(1.0).timeout
		player.hide()
		door.hide()
		cutscene.show()
		cutscene.play_cutscene()


func show_door_opening():
	await get_tree().create_timer(0.2).timeout
	set_process_input(false)
	doorcam.make_current()
	await get_tree().create_timer(0.2).timeout
	door.open_door()
	await get_tree().create_timer(2.0).timeout
	ending_area_3d.monitoring = true
	set_process_input(true)
	player.camera.make_current()


func _on_drone_died_signal() -> void:
	num_drones_killed += 1
	if num_drones_killed >= drones_required:
		show_door_opening()
	else:
		return
