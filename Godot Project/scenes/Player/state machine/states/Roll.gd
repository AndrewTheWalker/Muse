extends Move

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


# this var exists as a way to reference where the player will end up, which may someday be useful
# if we want to allow enemies to track it.
var endpoint : Vector3


#func default_lifecycle(input : InputPackage):
	#if transitions_to_queued(): 
		#if input.actions.has("sprint"):
			#print("action has sprint")
	#return "okay"

func update(input : InputPackage, delta : float):
	move_player(delta)


func on_enter_state():
	# this enter state function exists entirely just get the initial facing direction. 
	var input = area_awareness.last_input_package
	var input_direction = -(player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	input_direction.y = 0
	if input_direction:
		player.visuals.look_at(player.global_position - input_direction, Vector3.UP, false)
	player.send_sound("roll")


func on_exit_state():
	player.velocity = Vector3.ZERO


func move_player(delta : float):
	# step 1, get the root position vector defined by the roll_param animation. At each given frame of the anim, this value is different.
	# this is how we get the "preset" animation of the roll.
	var delta_pos = get_root_position_delta(delta)
	# we don't want to have any up/down movement, because we could be falling and we shouldn't be able to override that.
	delta_pos.y = 0
	

	var rotated_delta = -player.visuals.get_quaternion() * delta_pos / delta
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
