extends Node3D
class_name Targetable

@onready var parent : Node3D = $".."

@onready var look_at_point = $LookAt

func _ready():
	add_to_group("targetable")


func screen_entered():
	SignalBus.TARGET_SCREEN_ENTERED.emit(parent)
	
func screen_exited():
	SignalBus.TARGET_SCREEN_EXITED.emit(parent)
