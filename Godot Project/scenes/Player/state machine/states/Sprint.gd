extends Move
class_name Sprint

const SPEED = 8
const TURN_SPEED = 4.0

@onready var local_camera: CameraModel = $"../../../LocalCamera"

var orbit_target: Node3D 
var current_target: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation = "Sprint"


func on_enter_state():
	pass


func on_exit_state():
	pass


func default_lifecycle(input : InputPackage):
	if not player.is_on_floor():
		return "midair" 
	
	return best_input_that_can_be_paid(input)


func update(input : InputPackage, delta : float):

	player.move_and_slide()


func process_input_vector(input : InputPackage, delta : float):
	
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
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * SPEED
		player.rotate_y(angle)
