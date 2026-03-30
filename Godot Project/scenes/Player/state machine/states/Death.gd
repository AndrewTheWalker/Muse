extends Move
class_name Death


func _ready():
	pass

func check_relevance(input : InputPackage):
	return "okay"

func update(input : InputPackage, delta : float):
	pass

func on_enter_state():
	player.model.is_alive = false
	player.turn_off_emissive()
	player.send_sound("death_hit")
	SignalBus.PLAYER_DIED.emit()
	await get_tree().create_timer(3.0).timeout
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/deathscreen_gui.tscn")
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/null_3d.tscn")
	
func on_exit_state():
	pass
