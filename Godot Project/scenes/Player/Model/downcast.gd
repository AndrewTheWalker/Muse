extends RayCast3D


@onready var hip_sphere: CSGSphere3D = $hip_sphere
@onready var target_sphere: CSGSphere3D = $target_sphere
@onready var bone_target: ModifierBoneTarget3D = $"../../GeneralSkeleton/ModifierBoneTarget3D"


func _process(delta: float) -> void:
	global_position = bone_target.global_position
	var collision_point = get_collision_point()
	target_sphere.global_position = collision_point
	
