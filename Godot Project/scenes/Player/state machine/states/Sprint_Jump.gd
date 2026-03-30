extends Move

@export var SPEED = 6.0
@export var TURN_SPEED = 2.0
@export var VERTICAL_SPEED_ADDED : float = 2.5
@export var ANGULAR_SPEED = 7.0
@export var DELTA_VECTOR_LENGTH = 0.05

var jump_direction : Vector3

const TRANSITION_TIMING = 0.2
 
const JUMP_TIMING = 0.11

var jumped : bool = false


func default_lifecycle(_input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else: 
		return "okay"


func update(input : InputPackage, delta ):
	rotate_velocity(input,delta)
	process_jump()
	player.move_and_slide()


func rotate_velocity(input : InputPackage, delta : float):
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	var face_direction = -player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	input_direction.y = 0
	face_direction.y = 0
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = player.velocity.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta)
		face_direction = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = player.velocity.rotated(Vector3.UP, angle)
		face_direction = face_direction.rotated(Vector3.UP, angle)
		
	player.look_at(player.global_position + face_direction)
	
func process_jump():
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true

func jump_rotation(input: InputPackage, delta : float):
	var cam_basis = player.camera.basis
	var forward : Vector3 = cam_basis.z
	forward.y = 0
	forward = forward.normalized()
	var right : Vector3 = cam_basis.x
	right.y = 0
	right = right.normalized()
	
	var input_direction = (forward * -input.l_input_direction.y + right * input.l_input_direction.x).normalized()
	var face_direction = -player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= ANGULAR_SPEED * delta:
		player.velocity = player.velocity.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
		face_direction = face_direction.rotated(Vector3.UP, sign(angle) * ANGULAR_SPEED * delta)
	else:
		player.velocity = player.velocity.rotated(Vector3.UP, angle)
		face_direction = face_direction.rotated(Vector3.UP, angle)
	
	player.look_at(player.global_position - face_direction)


func on_enter_state():
	player.velocity = player.velocity.normalized() * SPEED
	player.send_sound("jump")
