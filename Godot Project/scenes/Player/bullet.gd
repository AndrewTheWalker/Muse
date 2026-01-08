extends Node3D
class_name Bullet

@onready var lifetime_timer: Timer = $Timer
@onready var hit_timer: Timer = $HitTimer

const BULLET_SPEED = 150.0
@onready var explode_particle: GPUParticles3D = $ExplodeParticle
@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D



func _ready():
	await lifetime_timer.timeout
	queue_free()

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-BULLET_SPEED) * delta


func hit() -> void:
	position = position
	csg_sphere_3d.hide()
	explode_particle.emitting = true
	hit_timer.start()
	await hit_timer.timeout
	queue_free()
