extends CharacterBody3D

'''THIS SCRIPT WILL SOON BE DEPRECATED AND REPLACED WITH PLAYERSM.GD'''

const DZ_WALK_THRESHOLD = 0.2
const DZ_RUN_THRESHOLD = 0.9

@onready var cam: CameraManager = $LocalCamera
@onready var animation_player: AnimationPlayer = $"visuals/exported-model/AnimationPlayer"
@onready var visuals: Node3D = $visuals

@export var speed = 2.5
@export var run_speed = 5.0

@export var jump_velocity = 4.5
@export var use_debug_cam := false

var orbit_target: Node3D
var target : Vector3
var orbit_speed : Vector3

func _ready() -> void:
	if !orbit_target:
		orbit_target = cam.camera_nest
	
	if use_debug_cam == false:
		cam.camera.make_current()
	else:
		print("debug camera active")

	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move()
	
func move():
	
	# move speed needs to be variable to accomodate changing speed later
	var move_speed = run_speed
	
	#get direction variables to exist
	var direction := Vector3.ZERO
	var orbit_direction : Vector3
	
	# to be changed later
	# target variable serves as orbit center. It is a vector3 representing target global position
	if orbit_target:
		target = orbit_target.global_position
	else:
		target = cam.camera.global_position
		move_speed = -move_speed
	
	# get the controller inputs, and the Vector 2 representing those inputs. We will need dirstr to set up our deadzone later
	var input_y := Input.get_axis("Lstick_down","Lstick_up")
	var input_x := Input.get_axis("Lstick_left","Lstick_right")
	var dirstr := Vector2(input_x,input_y)
	
	# the positions need to be Vector3s in order to work, but we don't want the Y axis messing things up, so they are 0
	var target_pos = Vector3(target.x,0.0,target.z)
	var player_pos = Vector3(self.global_position.x,0.0,self.global_position.z)
	
	# get the distance from the player to the target as a vector 3
	# and also get that vector's length to represent the radius of the orbit circle
	var target_dir = target_pos - player_pos
	var current_radius = target_dir.length()
	
	# if there is any input...
	if dirstr:
		if animation_player.current_animation != "Sprint":
			animation_player.play("Sprint")
			
		# just get the Y component, i.e. fwd bwd. The forward vector is going to be the line from/away from the orbit center.
		# direction.y has to be 0 because the camera can be anywhere on the Y axis.
		if input_y:
			direction = player_pos.direction_to(target_pos) * input_y * move_speed
			direction.y = 0.0
		
		# get the X component, i.e. side to side.
		# it's somewhat complicated, but this calculation slightly adjust the X movement so that it orbits the target position
		if input_x:
			var d = input_x * -move_speed / 60
			var theta = 2 * asin(d / (2*current_radius))
			var radius_b = target_dir.rotated(Vector3.UP,theta)
			var d_vector = target_pos - radius_b - player_pos
			orbit_direction =  d_vector * 60
			
		# now we simply add these two vectors and normalize them to get our final velocity
		velocity = (-direction + orbit_direction).normalized() * move_speed
		visuals.look_at(position+velocity)
				
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
