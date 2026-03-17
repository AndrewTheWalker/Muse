extends Move
class_name Overheat

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var model: PlayerModel = $"../.."

var is_overheating : bool = false

const TRANSITION_TIMING = 1.6667

func check_relevance(input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		is_overheating = false
		return "idle"
	else:
		return "okay"


func update(input : InputPackage, delta : float):
	player.velocity.y -= gravity * delta
	player.move_and_slide()

func on_enter_state():
	is_overheating = true
	model.fx_overheat.emit_particles()
	player.velocity = Vector3.ZERO
	player.send_sound("overheat")

func on_exit_state():
	is_overheating = false
	model.fx_overheat.stop_emitting()
