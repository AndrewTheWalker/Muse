extends Move
class_name Run



const WALK_SPEED = 2.5
const RUN_SPEED = 4.0


const TURN_SPEED = 2.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func default_lifecycle(input : InputPackage):
	if not player.is_on_floor():
		return "midair" 
	
	return best_input_that_can_be_paid(input)


func update(input : InputPackage, delta : float):
	player.velocity = rotate_velocity(input, delta)
	player.move_and_slide()


func rotate_velocity(input : InputPackage, delta : float) -> Vector3:
	# start by declaring our vector3
	var rotated_velocity : Vector3
	# input direction is the camera's basis multiplied by the input direction. Given how everything in my player scene is set up...
	# positive X and negative Y is the directions that I need to make it work.
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	# make sure the Y component is 0 because the camera points down a little bit.
	input_direction.y = 0
	
	# face direction is the fwd vector of the player visuals node. Simple enough.
	var face_direction = -(player.visuals.basis.z)

	# also make sure this one is 0 too. If this is ever not 0 things break!
	face_direction.y = 0
	
	# the point of this function is to make it so quickly pressing the opposite input direction will make the character
	# rotate around rather than immediately snap backwards in defiance of physics.
	
	# so, to make this work, we take the angle difference from the facing direction to the input direction.
	# if it is over the threshold of "tracking_angular_speed" we kinda slow down by making our speed "TURN_SPEED" instead of regular speed.
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		rotated_velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
	else:
		rotated_velocity = face_direction.rotated(Vector3.UP, angle) * RUN_SPEED
	
	player.visuals.look_at(player.global_position + player.velocity)
		
	return rotated_velocity
