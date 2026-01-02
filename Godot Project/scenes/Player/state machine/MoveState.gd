extends Node
class_name MoveState

#any time we want to leave the state, we call this signal
signal Transitioned

func Enter():
	pass

func Exit():
	pass
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	pass
