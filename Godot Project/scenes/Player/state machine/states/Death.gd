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

func on_exit_state():
	pass
