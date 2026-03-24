extends Move

@export var SPEED = 5.0
@export var VERTICAL_SPEED_ADDED : float = 4.0

const ANGULAR_SPEED = 7.0
const TRANSITION_TIMING = 0.33  
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
			#player.velocity = -(player.basis.z) * SPEED 
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true


func on_enter_state():
	player.velocity = player.velocity.normalized() * SPEED
	player.send_sound("jump")
