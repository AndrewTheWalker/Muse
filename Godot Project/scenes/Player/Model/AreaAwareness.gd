extends Node
class_name AreaAwareness

var last_pushback_vector : Vector3
var last_input_package : InputPackage

@onready var downcast = $Downcast as RayCast3D

# we've abstracted the floor raycast into its own class.
# my guess is that the benefit of doing it this way is allowing other states to query it more easily.

func get_floor_distance() -> float:
	if downcast.is_colliding():
		return downcast.global_position.distance_to(downcast.get_collision_point())
	return 9999

func get_look_at_point() -> Vector3:
	var point : Vector3
	return point
