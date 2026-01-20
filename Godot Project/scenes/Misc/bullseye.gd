extends Entity
class_name Bullseye

@onready var parent : Spawner = $".."

func receive_hit():
	print("ouch")
	parent.spawn_target()
	queue_free()
