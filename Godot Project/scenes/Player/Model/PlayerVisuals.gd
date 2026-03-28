extends Node3D
class_name PlayerVisuals


@onready var mesh: MeshInstance3D = $"Skinned Mesh 0"

@onready var model : PlayerModel



func accept_model(_model : PlayerModel):
	model = _model

	
func accept_skeleton(skeleton:Skeleton3D):
	mesh.skeleton = skeleton.get_path()
   
func _process(_delta):
	pass
