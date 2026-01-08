extends Node
class_name PlayerModel
# this class is the state machine

'''ADAPTED FROM CODE BY GAB OF THE FAIR FIGHT YOUTUBE CHANNEL'''

#debug for reticle stuff
@onready var reticle_half: Node3D = $"../ReticleHalf"

@onready var player = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SkeletonAnimator

@onready var bullet_spawner: Node3D = $"../Visuals/BulletSpawn"

var target_direction : Vector3

@onready var bullet_scene = preload("res://scenes/Player/bullet.tscn") as PackedScene

var current_move : Move

@onready var moves = {
	"idle" : $States/Idle,
	"run" : $States/Run,
	"jump" : $States/Jump,
	"sprint" : $States/Sprint,
	"midair" : $States/Midair,
	"land" : $States/Land,
	"roll" : $States/Roll,
	"sprintjump" : $States/Sprint_Jump,
	"sprintland" : $States/Sprint_Land,
}

# my previous version of the state machine had the ready function check the SM's children and append
# them to a state array in the ready function. In this case, we define the dictionary ourselves.
func _ready():
	print(player)
	current_move = moves["idle"]
	for move in moves.values():
		move.player = player

# call the moves check_relevance function. If it returns okay, then proceed
func update(input : InputPackage, reticle : Vector3, delta : float):
	var relevance = current_move.check_relevance(input)
	if relevance != "okay":
		switch_to(relevance)
	current_move.update(input, delta)
	var new_reticle_point = reticle
	update_bullet_target(new_reticle_point)
	# temporary little measure to make the run speed look faster
	if current_move is Sprint:
		animator.speed_scale = 1.5
	else:
		animator.speed_scale = 1.0

# calls the current move's exit function, switches to the new move, then calls the new move's enter function
func switch_to(state : String):
	current_move.on_exit_state()
	current_move = moves[state]
	current_move.on_enter_state()
	current_move.mark_enter_state()
	animator.play(current_move.animation)

func spawn_bullet():
	var spawn_loc = bullet_spawner.global_position
	var bullet = bullet_scene.instantiate()
	get_tree().get_root().add_child(bullet)
	bullet.transform.basis = bullet_spawner.global_transform.basis
	bullet.global_position = spawn_loc
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		spawn_bullet()

func update_bullet_target(reticle_point:Vector3):
	var spawn_loc = bullet_spawner.global_position
	target_direction = spawn_loc.direction_to(reticle_point)
	bullet_spawner.look_at(reticle_point)
	var halfway_mark = (spawn_loc + reticle_point)*0.5
	var quarter_mark = (spawn_loc + halfway_mark)*0.5
	reticle_half.global_position =quarter_mark
	reticle_half.look_at(spawn_loc)
	
