extends RigidBody3D
class_name Bullet

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var fx_hit = preload("res://scenes/FX/FX_BulletHit.tscn") as PackedScene

const BULLET_SPEED = 3.0
@export var bullet_damage : int = 10


func _ready():
	constant_force = transform.basis * Vector3(0,0,-BULLET_SPEED)
	await lifetime_timer.timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var hit_loc = ray_cast_3d.get_collision_point()
		ray_cast_3d.enabled = false
		hit(hit_loc)

# so at the present, my bullet uses BOTH a raycast and an area3D so they can kinda be backups for each other.
# both the area and the raycast call the same func and work more or less the same way.

func hit(hit_loc:Vector3):
	var hit_obj = ray_cast_3d.get_collider()
	if hit_obj:
		if hit_obj is HitBody:
			hit_obj.hit_request()
			print("requested via raycast")
	var inst = fx_hit.instantiate()
	csg_sphere_3d.hide()
	get_tree().get_root().add_child(inst)
	inst.transform.basis = self.global_transform.basis
	inst.global_position = hit_loc
	queue_free()


func _on_hurtbox_body_entered(body: Node3D) -> void:
	var loc = self.global_position
	if body is HitBody:
		body.hit_request()
		hit(loc)
		print("requested via hurtbox")


func get_hit_data() -> HitData:
	return HitData.blank()
