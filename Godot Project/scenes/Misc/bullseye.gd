extends Entity
class_name Bullseye

@onready var parent : Spawner = $".."

func receive_hit():
	print("ouch")
	SignalBus.TARGET_SCREEN_EXITED.emit(self)
	parent.spawn_target()
	queue_free()
