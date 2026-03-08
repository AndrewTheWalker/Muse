extends CharacterBody3D

@onready var explosion_scene = preload("res://scenes/FX/fx_drone_explosion.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_search_area: Area3D = $PlayerSearchArea
@onready var move_wait_timer: Timer = $MoveWaitTimer
@onready var secondary_wait_timer: Timer = $SecondaryWaitTimer
@onready var bone_attachment_3d: BoneAttachment3D = $Armature/Skeleton3D/BoneAttachment3D

const SPEED = 7.0

var look_at_node : Node3D
var player_detected : bool = false
var should_move : bool = false
var move_target : Vector3

func _ready() -> void:
	start_wait_timer()


func _process(delta: float) -> void:
	if player_detected:
		look_at(look_at_node.global_position,Vector3.UP,true)
	else:
		look_at(Vector3.FORWARD,Vector3.UP,true)
	
	if should_move:
		validate_should_move(move_target)
		move_to(move_target)
	
	else:
		velocity = lerp(velocity,Vector3.ZERO,0.5)
		
	move_and_slide()


func _on_player_search_area_body_entered(body: Node3D) -> void:
	if body.name == "PlayerKor":
		player_detected = true
		look_at_node = body


func _on_player_search_area_body_exited(body: Node3D) -> void:
	if body.name == "PlayerKor":
		player_detected = false


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
	if loc.y < 2.0 or loc.y > 10.0:
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
	velocity = Vector3.ZERO
	animation_player.play("Enemy_Dying")
	await animation_player.animation_finished
	var explosion = explosion_scene.instantiate()
	get_tree().get_root().add_child(explosion)
	explosion.global_position = bone_attachment_3d.global_position
	queue_free()
