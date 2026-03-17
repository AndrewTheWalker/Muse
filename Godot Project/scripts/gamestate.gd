extends Node

var game_controller: GameController

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func toggle_pause():
	print("toggle pause called")
	get_tree().paused = !get_tree().paused
