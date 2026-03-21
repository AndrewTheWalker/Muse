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

@onready var converging_particles: GPUParticles3D = $BulletSpawner/ConvergingParticles
@onready var growing_glow: GPUParticles3D = $BulletSpawner/GrowingGlow


@export var upper_bound : float
@export var lower_bound : float

const SPEED = 7.0

var look_at_node : Node3D
var player_detected : bool = false
var should_move : bool = false
var move_target : Vector3
var is_on_screen : bool = false

var health : int = 5

func _ready() -> void:
	start_wait_timer()


func _process(delta: float) -> void:
	if player_detected:
		look_at(look_at_node.global_position,Vector3.UP,true)
	#else:
		#return
	
	if should_move:
		validate_should_move(move_target)
		move_to(move_target)
	
	else:
		velocity = lerp(velocity,Vector3.ZERO,0.5)
		
	move_and_slide()


func _on_player_search_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerKor":
		player_detected = true
		send_sound("detect")
		look_at_node = body
		shot_timer.start()


func _on_player_search_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerKor":
		player_detected = false
		shot_timer.stop()


func start_wait_timer():
	var new_float = randf_range(3.0,8.0)
	move_wait_timer.wait_time = new_float
	move_wait_timer.start()


func choose_random_location()->Vector3:
	var current_loc : Vector3 = global_position
	var random_vector : Vector3
	var x = randf_range(-6.0,6.0)
	var y = randf_range(-3.0,3.0)
	var z = randf_range(-6.0,6.0)
	random_vector = Vector3(x,y,z)
	var new_loc = current_loc+random_vector
	return new_loc


func validate_target(loc:Vector3)->bool:
	if loc.y < lower_bound or loc.y > upper_bound:
		return false
	return true


func move_to(new_loc:Vector3):
	var direction = global_position.direction_to(new_loc)
	velocity = direction.normalized() * SPEED

func validate_should_move(loc:Vector3):
	if global_position.distance_to(loc) < 0.1:
		should_move = false
		move_wait_timer.start()


func _on_move_wait_timer_timeout() -> void:
	var new_loc = choose_random_location()
	if validate_target(new_loc) == true:
		move_target = new_loc
		should_move = true
	else:
		secondary_wait_timer.start()


func _on_secondary_wait_timer_timeout() -> void:
	_on_move_wait_timer_timeout()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DebugHurt"):
		die()
		

func die():
	move_wait_timer.stop()
	secondary_wait_timer.stop()
	send_sound("death_hit")
	SignalBus.TARGET_SCREEN_EXITED.emit(self)
	velocity = Vector3.ZERO
	animation_player.play("Enemy_Dying")
	await animation_player.animation_finished
	DIED_SIGNAL.emit()
	var explosion = explosion_scene.instantiate()
	get_tree().get_root().add_child(explosion)
	explosion.global_position = bone_attachment_3d.global_position
	queue_free()


func receive_hit():
	#if !player_detected:
		#player_detected = true
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
	if player_detected and is_on_screen:
		converging_particles.emitting = true
		send_sound("charge")
		growing_glow.emitting = true
		await converging_particles.finished
		spawn_bullet()
		send_sound("shoot")
		shot_timer.start()
	else:
		pass

func send_sound(sound_name : String):
	audio_manager.play_sound(sound_name)


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	is_on_screen = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	is_on_screen = false
