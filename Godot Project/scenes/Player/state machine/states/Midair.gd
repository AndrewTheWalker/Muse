extends Move
class_name Midair

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# something to consider about why we're doing what we're doing here:
# the is_on_floor check only works when the character's collider actually makes contact with the floor.
# this has no flexibility, and if our landing animation starts before contact is made, we can't use it.
# therefore we use a raycast. 

const DELTA_VECTOR_LENGTH = 0.1

@onready var downcast: RayCast3D = $"../../Downcast"
@onready var bone_target: ModifierBoneTarget3D = $"../../GeneralSkeleton/ModifierBoneTarget3D"

# tweak this later
var landing_height : float = 1.15
var jump_direction : Vector3



func _ready():
	animation = "Jump"
	move_name = "midair"

func check_relevance(input : InputPackage):
	var floor_point = downcast.get_collision_point()
	if bone_target.global_position.distance_to(floor_point) < landing_height:
		var xz_velocity = player.velocity
		xz_velocity.y = 0.0
		if xz_velocity.length_squared() >= 10:
			return "sprintland"
		return "land"
	else:
		return "okay"

func update(input : InputPackage, delta : float):
	rotate_humanoid(input,delta)
	player.velocity.y -= gravity * delta
	player.move_and_slide()


func rotate_humanoid(input : InputPackage, delta : float):
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	var input_delta_vector = input_direction * DELTA_VECTOR_LENGTH
	
	jump_direction = (jump_direction + input_delta_vector).limit_length(player.velocity.length())
	
	var new_velocity = (player.velocity + input_delta_vector).limit_length(player.velocity.length())
	player.velocity = new_velocity


func on_enter_state():
	jump_direction = Vector3(player.basis.z) * clamp(player.velocity.length(), 1, 999999)
	jump_direction.y = 0

func on_exit_state():
	pass
