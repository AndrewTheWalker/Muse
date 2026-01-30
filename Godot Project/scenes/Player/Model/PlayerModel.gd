extends Node
class_name PlayerModel



@onready var player = $".."
@onready var skeleton: Skeleton3D = %GeneralSkeleton
@onready var animator = $Animator
@onready var combat = $Combat as Combat
@onready var resources = $Resources as PlayerResources
# keep this.
#@onready var hurtbox = $Root/Hitbox as Hurtbox
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var current_move : Move
@onready var moves_container = $States as PlayerStates

# bullet related stuff
@onready var bullet_spawner: Node3D = $"../Visuals/BulletSpawn"
@onready var bullet_scene = preload("res://scenes/Player/Weapon/bullet.tscn") as PackedScene
@onready var reticle_half: Node3D = $"../ReticleHalf"

var target_direction : Vector3


# moves_container is the blank node that contains all states.

func _ready():
	moves_container.player = player
	moves_container.accept_moves()
	current_move = moves_container.moves["idle"]
	#switch_to("idle")



func update(input : InputPackage, reticle: Vector3, delta : float):
	# calling the combat class to contextualize the input has relevance for combos and the like. I think we don't need it.
	# input = combat.contextualize(input)
	
	# area awareness is a class that stores some information. In this case, area awareness will store the value of the current input, which we may wish to recall later
	area_awareness.last_input_package = input
	
	# relevance is what really decides what move we should be using. It basically asks "given the current input and context, does our state need to change, or is there a more *relevant* state that it *should* be?"
	# clicking through these functions will take you through the steps.
	var relevance = current_move.check_relevance(input)
	
	# after going on our long tiresome journey, and we find that everything checks out and that we are already in the state we should be in, then we do nothing.
	# however, if relevance DOES NOT equal "okay" then we call the switch_to function, and off we go.
	if relevance != "okay":
		switch_to(relevance)
	animator.update_body_animations()

	current_move.update_resources(delta)
	
	current_move._update(input, delta)

	var new_reticle_point = reticle
	
	# temporary little measure to make the run speed look faster
	# will be replaced by a proper anim eventually
	#if current_move is Sprint:
		#animator.speed_scale = 1.5
	#else:
		#animator.speed_scale = 1.0


func switch_to(state : String):
	print("switch_to called by: ", current_move.name, ". Requested transition to: ", state)
	current_move.base_on_exit_state()
	current_move = moves_container.moves[state]
	current_move.base_on_enter_state()


# bullet/reticle_stuff

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		spawn_bullet()


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


func update_bullet_target(reticle_point:Vector3):
	var spawn_loc = bullet_spawner.global_position
	target_direction = spawn_loc.direction_to(reticle_point)
	bullet_spawner.look_at(reticle_point)
	var halfway_mark = (spawn_loc + reticle_point) * 0.5
	var quarter_mark = (spawn_loc + halfway_mark) * 0.5
	reticle_half.global_position =quarter_mark
	reticle_half.look_at(spawn_loc)
