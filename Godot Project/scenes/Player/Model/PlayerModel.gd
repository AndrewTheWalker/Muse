extends Node
class_name PlayerModel

#@export var is_enemy : bool = false

# I don't know if I'm going to do the split legs thing, but I'll leave the commented code here.


@onready var player = $".."
@onready var skeleton: Skeleton3D = %GeneralSkeleton
#@onready var animator = $SplitBodyAnimator
@onready var animator = $SkeletonAnimator
@onready var combat = $Combat as Combat
@onready var resources = $Resources as PlayerResources
#@onready var hurtbox = $Root/Hitbox as Hurtbox
#@onready var legs = $Legs as Legs
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var current_move : Move
@onready var moves_container = $States as PlayerStates

# bullet related stuff
@onready var bullet_spawner: Node3D = $"../Visuals/BulletSpawn"
@onready var bullet_scene = preload("res://scenes/Player/Weapon/bullet.tscn") as PackedScene
@onready var reticle_half: Node3D = $"../ReticleHalf"

var target_direction : Vector3

# what's going on in here.
# moves_container is the blank node that contains all states.

func _ready():
	moves_container.player = player
	moves_container.accept_moves()
	current_move = moves_container.moves["idle"]
	print(current_move)
	switch_to("idle")
	#legs.current_legs_move = moves_container.get_move_by_name("idle")
	#legs.accept_behaviours()


func update(input : InputPackage, reticle: Vector3, delta : float):
	input = combat.contextualize(input)
	area_awareness.last_input_package = input
	var relevance = current_move.check_relevance(input)
	if relevance != "okay":
		switch_to(relevance)
	#print(animator.torso_animator.current_animation)
	current_move.update_resources(delta) # moved back here for now, because of TorsoMoves triggering _update from legs behaviour -> doubledipping
	current_move._update(input, delta)

	var new_reticle_point = reticle
	
	# temporary little measure to make the run speed look faster
	# will be replaced by a proper anim eventually
	if current_move is Sprint:
		animator.speed_scale = 1.5
	else:
		animator.speed_scale = 1.0



func switch_to(state : String):
	print(current_move.move_name + " -> " + state)
	current_move._on_exit_state()
	current_move = moves_container.moves[state]
	current_move._on_enter_state()


# bullet/reticle_stuff

func spawn_bullet():
	var spawn_loc = bullet_spawner.global_position
	var bullet = bullet_scene.instantiate()
	# so there's an error because we set these transforms before adding the bullet to the tree
	# but it doesn't work right if it's the other way around
	# this may be because the bullet's ready function determines its basis, so it's
	# probably being called too early. it's fine for now but remember to consider it later.
	bullet.global_position = spawn_loc
	bullet.transform.basis = bullet_spawner.global_transform.basis
	get_tree().get_root().add_child(bullet)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		spawn_bullet()

func update_bullet_target(reticle_point:Vector3):
	var spawn_loc = bullet_spawner.global_position
	target_direction = spawn_loc.direction_to(reticle_point)
	bullet_spawner.look_at(reticle_point)
	var halfway_mark = (spawn_loc + reticle_point) * 0.5
	var quarter_mark = (spawn_loc + halfway_mark) * 0.5
	reticle_half.global_position =quarter_mark
	reticle_half.look_at(spawn_loc)
	
