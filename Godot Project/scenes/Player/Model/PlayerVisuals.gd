extends Node3D
class_name PlayerVisuals


@onready var mesh: MeshInstance3D = $"Skinned Mesh 0"

@onready var model : PlayerModel

#@onready var beta_joints = $Beta_Joints
#@onready var beta_surface = $Beta_Surface



func accept_model(_model : PlayerModel):
	model = _model
	#beta_surface.skeleton = _model.skeleton.get_path()
	#beta_joints.skeleton = _model.skeleton.get_path()
	
func accept_skeleton(skeleton:Skeleton3D):
	mesh.skeleton = skeleton.get_path()
   
func _process(_delta):
	pass
