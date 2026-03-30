extends Move

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const TRANSITION_TIMING = 0.13

func on_enter_state():
	player.send_sound("land")

func default_lifecycle(input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		return best_input_that_can_be_paid(input)
	return "okay"


func update(_input : InputPackage, delta ):
	player.velocity.y -= gravity * delta
	player.velocity.x *= 0.8
	player.velocity.z *= 0.8
	player.move_and_slide()
