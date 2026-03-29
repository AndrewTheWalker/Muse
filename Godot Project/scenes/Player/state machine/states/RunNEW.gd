extends Move
class_name Run

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const WALK_SPEED = 2.5
const RUN_SPEED = 5.0
const TURN_SPEED = 2.0

var is_strafing : bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		is_strafing = true
	if event.is_action_released("Lock"):
		is_strafing = false
		if animation != "Jog":
			animation = "Jog"

func on_enter_state():
	player.send_sound("step")


func on_exit_state():
	player.stop_sound("step")


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
	
	player.move_and_slide()
	


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


func process_input_vector(input : InputPackage, delta : float):
	
	var cam_basis = player.camera.basis
	var forward : Vector3 = cam_basis.z
	forward.y = 0
	forward = forward.normalized()
	var right : Vector3 = cam_basis.x
	right.y = 0
	right = right.normalized()
	
	if ! is_strafing:
		var input_direction = (forward * -input.l_input_direction.y + right * input.l_input_direction.x).normalized()
		var face_direction = -player.basis.z
		var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
		if abs(angle) >= tracking_angular_speed * delta:
			player.velocity = face_direction.rotated(Vector3.UP, sign(angle) * tracking_angular_speed * delta) * TURN_SPEED
			player.rotate_y(sign(angle) * tracking_angular_speed * delta)
		else:
			player.velocity = face_direction.rotated(Vector3.UP, angle) * RUN_SPEED
			player.rotate_y(angle)
			
	else:
		var input_direction = (forward * -input.l_input_direction.y + right * input.l_input_direction.x).normalized()
		player.velocity.x = input_direction.x * RUN_SPEED*0.5
		player.velocity.z = input_direction.z * RUN_SPEED*0.5
		var face_direction = player.local_camera.get_projected_position()
		face_direction.y = player.global_position.y
		player.look_at(face_direction)
		choose_anim(input,face_direction)
		
		
	#animator.set_speed_scale(player.velocity.length() / RUN_SPEED)
