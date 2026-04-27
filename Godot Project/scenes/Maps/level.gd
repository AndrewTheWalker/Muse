extends Node3D
class_name LevelManager

@export var player : PlayerKor
@export var cutscene : Cutscene
@onready var ending_area_3d: Area3D = $EndingArea3D

@onready var door: Node3D = $LEVEL_GEO/Door
@onready var doorcam: Camera3D = $LEVEL_GEO/Door/Doorcam

@onready var world_environment: WorldEnvironment = $WorldEnvironment

var num_drones_killed : int = 0
@export var drones_required : int

func _ready() -> void:
	ending_area_3d.monitoring = false
	cutscene.hide()
	SignalBus.connect("PLAYER_DIED",on_player_death)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalBus.CUTSCENE_ACTIVATED.emit()
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
	drones_required -= 1
	print("drone killed, num left is ",drones_required)
	if drones_required < 1:
		show_door_opening()
	else:
		return

func on_player_death():
	var tween = create_tween()
	Gamestate.game_controller.current_gui_scene.hide()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(world_environment,"environment:adjustment_saturation",0.0,2.0)
	tween.parallel().tween_property(world_environment,"environment:adjustment_brightness",0.0,3.0)
	await tween.finished
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/deathscreen_gui.tscn")
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/null_3d.tscn")
