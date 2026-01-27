extends Node3D
class_name PlayerVisuals

@onready var mesh: MeshInstance3D = $"Skinned Mesh 0"

func accept_skeleton(skeleton:Skeleton3D):
	mesh.skeleton = skeleton.get_path()
