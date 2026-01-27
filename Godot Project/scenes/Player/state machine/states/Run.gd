extends Move
class_name Run

'''NOTE TO SELF: FIGURE OUT HOW TO DO THE WALK DEADZONE THING HERE
Why not make separate states? Because the walk/run behaviour and transition logic is the same, its just cosmetic'''

@onready var debug_sphere: CSGSphere3D = $"../../../CSGSphere3D"


const WALK_SPEED = 2.5
const RUN_SPEED = 4.5

@onready var local_camera: CameraModel = $"../../../LocalCamera"

var orbit_target: Node3D 
var orbit_target_loc: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation = "Run"
	
func on_enter_state():
	print("entered run")
	orbit_target = local_camera.camera_nest

func on_exit_state():
	pass

# the SM's check relevance function expects to receive the "okay" string before proceeding
func check_relevance(input : InputPackage):
	if !player.is_on_floor():
		return "midair"
	
	input.actions.sort_custom(moves_priority_sort)
	if input.actions[0] == "run":
		return "okay"
	return input.actions[0]
	

func update(input : InputPackage, delta : float):
	var slight_offset = Vector3(0.0001, 0.0001, 0.0001) # A very small offset
	player.velocity = velocity_by_input(input, delta)
	player.move_and_slide()

func velocity_by_input(input : InputPackage, delta : float) -> Vector3:
	# move speed needs to be variable to accomodate changing speed later
	var move_speed = RUN_SPEED
	var new_direction : Vector3
	
	var new_velocity = player.velocity
	var orbit_direction : Vector3
	
	var target_pos = orbit_target_loc
	target_pos.y = 0.0
	var player_pos = player.global_position
	player_pos.y = 0.0
	
	# used for calculating x axis orbit
	var target_dir = target_pos - player_pos
	var orbit_radius = target_dir.length()
	
	if orbit_target:
		orbit_target_loc = orbit_target.global_position
	# get the controller inputs, and the Vector 2 representing those inputs. We will need dirstr to set up our deadzone later
	var input_direction = (player.transform.basis * Vector3(input.l_input_direction.x, 0, input.l_input_direction.y)).normalized()
	
	# if there is any input...
	if input_direction:
		if input_direction.z:
			new_direction = player_pos.direction_to(target_pos) * input_direction.z * move_speed
			new_direction.y = 0.0
		if input_direction.x:
			var d = input_direction.x * -move_speed / 60
			var theta = 2 * asin(d / (2*orbit_radius))
			var radius_b = target_dir.rotated(Vector3.UP,theta)
			var d_vector = target_pos - radius_b - player_pos
			orbit_direction =  d_vector * 60
		new_velocity = (-new_direction + orbit_direction).normalized() * move_speed
		
		
		
		# may be refactored later. the addition of that one Vec3 is just so i stop getting the annoying error
		player.visuals.look_at(player.global_position+(new_velocity+Vector3(0.0,0.0,0.1)))
		
	else:
		new_velocity.x = move_toward(new_velocity.x, 0, delta)
		new_velocity.z = move_toward(new_velocity.z, 0, delta)
		
	if not player.is_on_floor():
		new_velocity.y -= gravity * delta
	
	return new_velocity
