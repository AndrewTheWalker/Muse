extends RigidBody3D
class_name PhysicsBullet

const BULLET_SPEED = 3.0

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var hit_timer: Timer = $HitTimer
@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var fx_hit = preload("res://scenes/FX/FX_BulletHit.tscn") as PackedScene

func _ready():
	constant_force = transform.basis * Vector3(0,0,-BULLET_SPEED)
	await lifetime_timer.timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		ray_cast_3d.enabled = false
		hit()
	
func hit():
	print("bullet raycast hit")
	var hit_loc = ray_cast_3d.get_collision_point()
	var inst = fx_hit.instantiate()
	csg_sphere_3d.hide()
	get_tree().get_root().add_child(inst)
	inst.transform.basis = self.global_transform.basis
	inst.global_position = hit_loc
	queue_free()
