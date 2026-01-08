extends Node3D
class_name Bullet

@onready var timer: Timer = $Timer

const BULLET_SPEED = 550.0

func _ready():
	await timer.timeout
	delete()

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-BULLET_SPEED) * delta

func delete():
	queue_free()
