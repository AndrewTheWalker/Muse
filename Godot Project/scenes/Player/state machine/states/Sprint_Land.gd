extends Move
class_name SprintLand

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const TRANSITION_TIMING = 0.25

func _ready():
	animation = "Jump_Land"
	move_name = "sprintland"

func check_relevance(input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		input.actions.sort_custom(moves_priority_sort)
		return input.actions[0]
	else:
		return "okay"

func update(input : InputPackage, delta : float):
	player.velocity.y -= gravity * delta
	player.move_and_slide()

func on_enter_state():
	print("entered sprint land")

func on_exit_state():
	pass
