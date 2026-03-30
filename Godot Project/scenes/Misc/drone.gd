extends CharacterBody3D



const explosion_scene = preload("uid://crgr1jn1joc2h")
const bullet_scene = preload("uid://bg7rl84y6o0p7")

signal DIED_SIGNAL

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_search_area: Area3D = $PlayerSearchArea
@onready var move_wait_timer: Timer = $MoveWaitTimer
@onready var secondary_wait_timer: Timer = $SecondaryWaitTimer
@onready var bone_attachment_3d: BoneAttachment3D = $Armature/Skeleton3D/BoneAttachment3D
@onready var bullet_spawner: Node3D = $BulletSpawner
@onready var shot_timer: Timer = $ShotTimer
@onready var audio_manager: Node = $AudioManager

@onready var laser_sight: Node3D = $LaserSight
@onready var laser_ray_cast_3d: RayCast3D = $LaserRayCast3D

@onready var converging_particles: GPUParticles3D = $BulletSpawner/ConvergingParticles
@onready var growing_glow: GPUParticles3D = $BulletSpawner/GrowingGlow

@onready var hit_body: HitBody = $HitBody


var y_bounds : Vector2
var x_bounds : Vector2
var z_bounds : Vector2

const SPEED = 7.0

var look_at_node : Node3D
var player_detected : bool = false
var move_target : Vector3
var should_move : bool

var health : int = 5

func _ready() -> void:
	find_player()
	start_wait_timer()
	var spawn_loc : Vector3 = global_position
	x_bounds = Vector2(spawn_loc.x-5.0,spawn_loc.x+5.0)
	y_bounds = Vector2(spawn_loc.y-3.0,spawn_loc.y+3.0)
	z_bounds = Vector2(spawn_loc.z-5.0,spawn_loc.z+5.0)
	laser_sight.visible = false

func find_player():
	var player = get_tree().get_first_node_in_group("player")
	look_at_node = player

func _process(delta: float) -> void:
	var look_target = look_at_node.global_position+Vector3(0.0,1.0,0.0)
	
	laser_sight.look_at(look_target,Vector3.UP,true)
	
	if laser_ray_cast_3d.is_colliding():
		laser_sight.scale.z = global_position.distance_to(laser_ray_cast_3d.get_collision_point())
			
	if player_detected:
		look_at(look_at_node.global_position,Vector3.UP,true)
		
	
	if should_move:
		validate_should_move(move_target)
		move_to(move_target)
			
	else:
		velocity = lerp(velocity,Vector3.ZERO,0.5)
		
	move_and_slide()


func _on_player_search_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerKor":
		look_at_node = body
		player_detected = true
		send_sound("detect")
		_on_shot_timer_timeout()
		shot_timer.start()
		if laser_ray_cast_3d.is_colliding():
			var collision_object = laser_ray_cast_3d.get_collider()
			#if collision_object.name == "PlayerKor":
				


func _on_player_search_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerKor":
		player_detected = false
		shot_timer.stop()


func start_wait_timer():
	var new_float = randf_range(0.5,5.0)
	move_wait_timer.wait_time = new_float
	move_wait_timer.start()


func choose_random_location()->Vector3:
	var current_loc : Vector3 = global_position
	var random_vector : Vector3
	var x = randf_range(-3.0,3.0)
	var y = randf_range(-1.0,1.0)
	var z = randf_range(-3.0,3.0)
	random_vector = Vector3(x,y,z)
	var new_loc = current_loc+random_vector
	return new_loc


func validate_target(loc:Vector3)->bool:
	var x_valid : bool = true
	var y_valid : bool = true
	var z_valid : bool = true
	
	if loc.x < x_bounds.x or loc.x > x_bounds.y:
		x_valid = false
	if loc.y < y_bounds.x or loc.y > y_bounds.y:
		y_valid = false
	if loc.z < z_bounds.x or loc.z > z_bounds.y:
		z_valid = false
	
	if x_valid && y_valid && z_valid:
		return true
	else:
		return false


func validate_should_move(loc:Vector3):
	if global_position.distance_to(loc) < 0.1:
		should_move = false
		start_wait_timer()


func move_to(new_loc:Vector3):
	var direction = global_position.direction_to(new_loc)
	velocity = direction.normalized() * SPEED


func _on_move_wait_timer_timeout() -> void:
	var new_loc = choose_random_location()
	if validate_target(new_loc) == true:
		move_target = new_loc
		should_move = true
		start_wait_timer()
	else:
		secondary_wait_timer.start()


func _on_secondary_wait_timer_timeout() -> void:
	_on_move_wait_timer_timeout()


func die():
	move_wait_timer.stop()
	secondary_wait_timer.stop()
	send_sound("death_hit")
	hit_body.disable()
	SignalBus.TARGET_SCREEN_EXITED.emit(self)
	velocity = Vector3.ZERO
	animation_player.play("Enemy_Dying")
	await animation_player.animation_finished
	var explosion = explosion_scene.instantiate()
	get_tree().get_root().add_child(explosion)
	explosion.global_position = bone_attachment_3d.global_position
	DIED_SIGNAL.emit()
	queue_free()


func receive_hit():
	look_at(look_at_node.global_position,Vector3.UP,true)
	health -= 1
	send_sound("hit")
	if health < 1:
		die()


func spawn_bullet():
	var spawn_loc = bullet_spawner.global_position
	var bullet = bullet_scene.instantiate()
	
	# Note to self. We do not declare that "bullet" is the bullet class at any point here. Therefore we don't get autofill.
	# This works, but might be prone to breaking if I screw something up.
	
	bullet.type = "player"
	bullet.spawn_pos = spawn_loc
	bullet.spawn_basis = bullet_spawner.global_transform.basis
	get_tree().get_root().add_child(bullet)


func _on_shot_timer_timeout() -> void:
	if player_detected:
		converging_particles.emitting = true
		send_sound("charge")
		laser_sight.visible = true
		growing_glow.emitting = true
		await converging_particles.finished
		spawn_bullet()
		laser_sight.visible = false
		send_sound("shoot")
		shot_timer.start()
	else:
		pass


func send_sound(sound_name : String):
	audio_manager.play_sound(sound_name)
