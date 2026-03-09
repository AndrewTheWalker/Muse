extends RigidBody3D
class_name Bullet

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var csg_sphere_3d: CSGSphere3D = $CSGSphere3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var fx_hit = preload("res://scenes/FX/FX_BulletHit.tscn") as PackedScene


var type: String = "enemy"


const BULLET_SPEED = 3.0
var bullet_damage : int = 10

var spawn_pos : Vector3
var spawn_basis : Basis


func _ready():
	if type == "enemy":
		ray_cast_3d.set_collision_mask_value(4,true)
	elif type == "player":
		ray_cast_3d.set_collision_mask_value(5,true)
	global_position = spawn_pos
	global_basis = spawn_basis
	constant_force = global_basis * Vector3(0,0,-BULLET_SPEED)
	await lifetime_timer.timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var hit_loc = ray_cast_3d.get_collision_point()
		ray_cast_3d.enabled = false
		hit(hit_loc)


# I stopped using the Entity class (for now) so calling hit_request is also slightly risky.

func hit(hit_loc:Vector3):
	var hit_obj = ray_cast_3d.get_collider()
	if hit_obj:
		if hit_obj is HitBody:
			print(hit_obj.name)
			if hit_obj.type == type:
				hit_obj.hit_request()
				print("bullet hit")
			else:
				print("bullet hit, but the types didn't match")
			
	var inst = fx_hit.instantiate()
	csg_sphere_3d.hide()
	get_tree().get_root().add_child(inst)
	inst.transform.basis = self.global_transform.basis
	inst.global_position = hit_loc
	queue_free()














# outdated functions, keeping for reference.

#func _on_hurtbox_body_entered(body: Node3D) -> void:
	#var loc = self.global_position
	#if body is HitBody:
		#body.hit_request()
		#hit(loc)
		#print("requested via hurtbox")
#
#
#func get_hit_data() -> HitData:
	#return HitData.blank()
