
extends Move

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var downcast: RayCast3D = $"../../AreaAwareness/Downcast"
@onready var hip_attachment: BoneAttachment3D = $"../../GeneralSkeleton/Root"


@export var DELTA_VECTOR_LENGTH = 0.01
var jump_direction : Vector3

var landing_height : float = 1.15


func default_lifecycle(_input : InputPackage):
	var floor_point = downcast.get_collision_point()
	if hip_attachment.global_position.distance_to(floor_point) < landing_height:
		var xz_velocity = player.velocity
		xz_velocity.y = 0
		#if xz_velocity.length_squared() >= 10:
			#return "sprintland"
		return "land"
	else:
		return "okay"


func update(input : InputPackage, delta):
	process_input_vector(input,delta)
	player.velocity.y -= (gravity * 1.2) * delta
	player.move_and_slide()


func process_input_vector(input : InputPackage, delta : float):
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	input_direction.y = 0
	var input_delta_vector = input_direction * DELTA_VECTOR_LENGTH
	
	jump_direction = (jump_direction + input_delta_vector).limit_length(player.velocity.length())
	
	
	var new_velocity = (player.velocity + input_delta_vector).limit_length(player.velocity.length())
	player.velocity = new_velocity
	new_velocity.y = 0
	#player.visuals.look_at(player.global_position + new_velocity)


func on_enter_state():
	jump_direction = -(player.basis.z) * clamp(player.velocity.length(), 1, 999999)
	jump_direction.y = 0
