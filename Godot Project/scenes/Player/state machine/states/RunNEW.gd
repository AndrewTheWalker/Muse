extends Move
class_name Run

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const WALK_SPEED = 2.5
const RUN_SPEED = 4.0
const TURN_SPEED = 3.0

var is_strafing : bool = false

var look_at_position : Vector3

enum STATES {
	WALK_FW,
	WALK_FL,
	WALK_FR,
	WALK_BW,
	WALK_BL,
	WALK_BR,
	JOG_FW,
	JOG_FL,
	JOG_FR,
	JOG_BW,
	JOG_BL,
	JOG_BR
	}


func on_enter_state():
	SignalBus.connect("TARGET_LOCKED",determine_look_at)
	SignalBus.connect("TARGET_DROPPED",determine_look_at)


func determine_look_at(thing_to_look_at:Node3D):
	if thing_to_look_at:
		look_at_position = thing_to_look_at.global_position
	else:
		look_at_position = Vector3(0,0,1)

func default_lifecycle(input : InputPackage):
	if not player.is_on_floor():
		return "midair" 
	
	return best_input_that_can_be_paid(input)


func update(input : InputPackage, delta : float):
	player.velocity = rotate_velocity(input, delta)
	player.move_and_slide()
	player.visuals.look_at(player.global_position + player.velocity)

func rotate_velocity(input : InputPackage, delta : float) -> Vector3:
	var rotated_velocity : Vector3
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	input_direction.y = 0
	var face_direction = -(player.visuals.basis.z)
	face_direction.y = 0
	
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	
	if abs(angle) >= tracking_angular_speed * delta:
		rotated_velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
	else:
		rotated_velocity = face_direction.rotated(Vector3.UP, angle) * RUN_SPEED
	
	return rotated_velocity
