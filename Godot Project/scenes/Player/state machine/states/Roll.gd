extends Move

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var endpoint : Vector3

func _ready():
	animation = "Roll"


func update(input : InputPackage, delta : float):
	move_player(delta)

func on_enter_state():
	var input = area_awareness.last_input_package
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	if input_direction:
		player.look_at(player.global_position + input_direction, Vector3.UP, true)
func on_exit_state():
	pass


func move_player(delta : float):
	var delta_pos = get_root_position_delta(delta)
	delta_pos.y = 0
	var rotated_delta = player.get_quaternion() * delta_pos / delta
	player.velocity.x = rotated_delta.x
	player.velocity.z = rotated_delta.z
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	player.move_and_slide()

func best_input_that_can_be_paid(input : InputPackage) -> String:
	input.actions.sort_custom(container.moves_priority_sort)
	for action in input.actions:
		if resources.can_be_paid(container.moves[action]):
			return action
			#if container.moves[action] == self:
				#return "okay"
			#else:
				#return action
	return "throwing because for some reason input.actions doesn't contain even idle"  
