extends Node
class_name CameraState

signal Transitioned

func Enter():
	pass
	
func Exit():
	pass

func Update(look_at:Node3D, delta: float) -> void:
	pass
	
func Physics_Update(look_at:Node3D, delta: float) -> void:
	pass
	
func input_axis_motion(d_hor:float,d_ver:float):
	pass
	
func input_target_lock(event: InputEvent):
	pass
