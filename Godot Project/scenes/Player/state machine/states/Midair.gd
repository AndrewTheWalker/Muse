extends Move
class_name Midair

# something to consider about why we're doing what we're doing here:
# the is_on_floor check only works when the character's collider actually makes contact with the floor.
# this has no flexibility, and if our landing animation starts before contact is made, we can't use it.
# therefore we use a raycast. 

@onready var downcast: RayCast3D = $"../../Downcast"
@onready var bone_target: ModifierBoneTarget3D = $"../../GeneralSkeleton/ModifierBoneTarget3D"

# tweak this later
var landing_height : float = 1.15

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


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
	player.velocity.y -= gravity * delta
	player.move_and_slide()


func on_enter_state():
	pass

func on_exit_state():
	pass
