extends Node
class_name Combo

@onready var move : Move
@export var triggered_move : String

func is_triggered(_input : InputPackage) -> bool:
	return false
