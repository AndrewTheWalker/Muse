extends Move
class_name Run

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const WALK_SPEED = 2.5
const RUN_SPEED = 4.0
const TURN_SPEED = 3.0

var is_strafing : bool = false

var look_at_position : Vector3


func on_enter_state():
	# for some reason this function was giving an error that the signal is already connected. I had to add some if statements
	# to make it stop, but I really don't know why it happened all of a sudden. Oh well?
	if ! SignalBus.is_connected("TARGET_DROPPED",drop_look_at):
		SignalBus.connect("TARGET_LOCKED",set_look_at)
	if ! SignalBus.is_connected("TARGET_DROPPED",drop_look_at):
		SignalBus.connect("TARGET_DROPPED",drop_look_at)
	player.send_sound("step")
	#look_at_position = player.global_position + player.velocity

func on_exit_state():
	player.stop_sound("step")

func set_look_at(look_at_vector:Vector3):
	if look_at_vector:
		is_strafing = true
		look_at_position = look_at_vector
		look_at_position.y = 0
		player.look_at(look_at_position)


func drop_look_at():
	is_strafing = false
	if animation != "Jog":
		animation = "Jog"


func default_lifecycle(input : InputPackage):
	if not player.is_on_floor():
		return "midair" 
	
	return best_input_that_can_be_paid(input)

func queue_condition(input : InputPackage):
	if input.l_input_direction != Vector2.ZERO and !input.actions.has("sprint"):
		return true
	else:
		return false

func update(input : InputPackage, delta : float):
	rotate_velocity(input,delta)
	player.move_and_slide()
	if is_strafing:
		player.look_at(look_at_position)
		choose_anim(input,look_at_position)
	else:
		return
		#player.look_at(player.global_position + player.velocity)


func choose_anim(input:InputPackage,target:Vector3):
	var direction = find_direction(input,target)
	match direction:
		"forward":
			animation = "Jog"
		"forward left":
			animation = "Jog_FL"
		"forward right":
			animation = "Jog_FR"
		"backward left":
			animation = "Jog_BL"
		"backward right":
			animation = "Jog_BR"
		"backward":
			animation = "Jog_BWD"


func find_direction(input:InputPackage,target:Vector3) -> String:
	
	var target_direction = player.global_position.direction_to(target)
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	var x_direction = input.l_input_direction.x
	var angle = input_direction.angle_to(target_direction)
	var ab_diff = rad_to_deg(angle)
	var direction_name : String = "forward"

	if ab_diff >120 and ab_diff <= 180.0:
		direction_name = "backward"
		
	if x_direction <0:
		if ab_diff >0 and ab_diff <= 30.0:
			direction_name = "forward"
		if ab_diff >30 and ab_diff <= 90.0:
			direction_name = "forward left"
		if ab_diff >90 and ab_diff <= 120.0:
			direction_name = "backward left"

	if x_direction >0:
		if ab_diff >0 and ab_diff <= 30.0:
			direction_name = "forward"
		if ab_diff >30 and ab_diff <= 90.0:
			direction_name = "forward right"
		if ab_diff >90 and ab_diff <= 120.0:
			direction_name = "backward right"

	return direction_name


func rotate_velocity(input : InputPackage, delta : float):
	var face_direction := -(player.basis.z)
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	input_direction.y = 0
	face_direction.y = 0
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * RUN_SPEED


func process_input_vector(input : InputPackage, delta : float):
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	var face_direction = -player.basis.z
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	if abs(angle) >= tracking_angular_speed * delta:
		player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
		player.rotate_y(sign(angle) * tracking_angular_speed * delta)
	else:
		player.velocity = face_direction.rotated(Vector3.UP, angle) * RUN_SPEED
		player.rotate_y(angle)
	#animator.set_speed_scale(player.velocity.length() / RUN_SPEED)



func velocity_by_input(input:InputPackage,delta:float)-> Vector3:
	var new_velocity = player.velocity
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	new_velocity.x = input_direction.x * RUN_SPEED
	new_velocity.z = input_direction.z * RUN_SPEED
	
	return new_velocity
