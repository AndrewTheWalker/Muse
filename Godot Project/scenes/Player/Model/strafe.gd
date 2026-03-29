extends Move
class_name Strafe


const WALK_SPEED = 2.0
const RUN_SPEED = 4.0
const TURN_SPEED = 2.0



func update(input : InputPackage, delta : float):
	pass

func on_enter_state():
	pass

func on_exit_state():
	pass

func process_input_vector(input : InputPackage, delta : float):
	var cam_basis = player.camera.basis
	var forward : Vector3 = cam_basis.z
	forward.y = 0
	forward = forward.normalized()
	var right : Vector3 = cam_basis.x
	right.y = 0
	right = right.normalized()
	
	var input_direction = (forward * -input.l_input_direction.y + right * input.l_input_direction.x).normalized()
	player.velocity.x = input_direction.x * RUN_SPEED*0.75
	player.velocity.z = input_direction.z * RUN_SPEED*0.75
