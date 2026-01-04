extends Move
class_name Idle


func _ready():
	animation = "Idle"

func check_relevance(input) -> String:
	input.actions.sort_custom(moves_priority_sort)
	return input.actions[0]

func on_enter_state():
	if player.velocity:
		player.velocity = Vector3.ZERO

func update(input : InputPackage, delta : float):
	pass
