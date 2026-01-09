extends Node3D
class_name Bullet

const BULLET_SPEED = 150.0

@onready var lifetime_timer: Timer = $Timer
@onready var hit_timer: Timer = $HitTimer
@onready var explode_particle: GPUParticles3D = $ExplodeParticle
@onready var visuals: CSGSphere3D = $CSGSphere3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var fx_hit = preload("res://scenes/FX/FX_BulletHit.tscn") as PackedScene


func _ready():
	
	await lifetime_timer.timeout
	queue_free()

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-BULLET_SPEED) * delta

func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		ray_cast_3d.enabled = false
		hit()

func hit() -> void:
	print("bullet raycast hit")
	var hit_loc = ray_cast_3d.get_collision_point()
	var inst = fx_hit.instantiate()
	visuals.hide()
	get_tree().get_root().add_child(inst)
	inst.transform.basis = self.global_transform.basis
	inst.global_position = hit_loc
	queue_free()
