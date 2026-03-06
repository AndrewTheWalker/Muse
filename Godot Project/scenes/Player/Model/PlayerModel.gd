extends Node
class_name PlayerModel



@onready var player = $".."
@onready var skeleton: Skeleton3D = %GeneralSkeleton
@onready var animator = $Animator
@onready var combat = $Combat as Combat
@onready var resources = $Resources as PlayerResources
@onready var ik_controller = $IKController as IKController
@onready var ctrl_rig: Node3D = $CtrlRig


# keep this.
#@onready var hurtbox = $Root/Hitbox as Hurtbox
@onready var area_awareness = $AreaAwareness as AreaAwareness

@onready var current_move : Move
@onready var moves_container = $States as PlayerStates

# bullet related stuff
@onready var bullet_spawner: Node3D = $"../Visuals/BulletSpawn"
@onready var bullet_scene = preload("res://scenes/Player/Weapon/bullet.tscn") as PackedScene
@onready var reticle_half: Node3D = $"../ReticleHalf"
@onready var gun_point: BoneAttachment3D = $GeneralSkeleton/GunPoint

@onready var fx_overheat: OverheatFX = $FX_Overheat


var target_direction : Vector3

var is_shooting : bool = false
var is_alive : bool = true

# moves_container is the blank node that contains all states.

func _ready():
	SignalBus.connect("OVERHEATING",force_overheat)
	moves_container.player = player
	moves_container.accept_moves()
	current_move = moves_container.moves["idle"]
	#switch_to("idle")


func update(input : InputPackage, reticle: Vector3, delta : float):
	if is_alive:
	
		area_awareness.last_input_package = input

		var relevance = current_move.check_relevance(input)
		
		if relevance != "okay":
			switch_to(relevance)
		
		animator.update_body_animations()
		current_move.update_resources(delta)
		current_move._update(input, delta)
		
		var new_reticle_point = reticle
		update_bullet_target(new_reticle_point)

	fx_overheat.global_position = gun_point.global_position

func switch_to(state : String):
	print(current_move.name, "-->", state)
	current_move.base_on_exit_state()
	current_move = moves_container.moves[state]
	current_move.base_on_enter_state()



func rotate_rig():
	pass

# bullet/reticle_stuff

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		if current_move.can_shoot():
			SignalBus.TARGET_LOCKED.emit(target_direction)
			ik_controller.process_ik("shoot")
			call_deferred("spawn_bullet")
		else:
			print("shooting not allowed by this move")
	if event.is_action_released("Shoot"):
		
		ik_controller.process_ik("release")
	if event.is_action_pressed("DebugHurt"):
		resources.lose_health(20.0)

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
	resources.lose_stamina(15.0)


func update_bullet_target(reticle_point:Vector3):
	var spawn_loc = bullet_spawner.global_position
	target_direction = reticle_point
	bullet_spawner.look_at(reticle_point)


func force_overheat():
	current_move.try_force_move("overheat")
	ik_controller.override()
