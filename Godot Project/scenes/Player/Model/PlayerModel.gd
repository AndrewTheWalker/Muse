extends Node
class_name PlayerModel

@export var print_transition_statements : bool = true

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
const bullet_scene = preload("uid://bg7rl84y6o0p7")
@onready var bullet_spawner: Node3D = $"../Visuals/BulletSpawn"
@onready var reticle_half: Node3D = $"../ReticleHalf"
@onready var gun_point: BoneAttachment3D = $GeneralSkeleton/GunPoint
@onready var modifier_bone_target_3d: ModifierBoneTarget3D = $GeneralSkeleton/ModifierBoneTarget3D

@onready var fx_overheat: OverheatFX = $FX_Overheat
@onready var sparks: GPUParticles3D = $Sparks


var target_direction : Vector3

var is_shooting : bool = false
var is_alive : bool = true

# moves_container is the blank node that contains all states.

func _ready():
	SignalBus.connect("OVERHEATING",force_overheat)
	moves_container.player = player
	moves_container.accept_moves()
	current_move = moves_container.moves["idle"]
	switch_to("idle")


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
	sparks.global_position = modifier_bone_target_3d.global_position

func switch_to(state : String):
	if print_transition_statements:
		print(current_move.name, "-->", state)
	current_move.base_on_exit_state()
	current_move = moves_container.moves[state]
	current_move.base_on_enter_state()



func rotate_rig():
	pass

# bullet/reticle_stuff

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		if current_move.can_shoot():
			SignalBus.TARGET_LOCKED.emit(target_direction)
			ik_controller.process_ik("shoot")
			player.send_sound("shoot")
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
	
	# Note to self. We do not declare that "bullet" is the bullet class at any point here. Therefore we don't get autofill.
	# This works, but might be prone to breaking if I screw something up.
	
	bullet.type = "enemy"
	bullet.spawn_pos = spawn_loc
	bullet.spawn_basis = bullet_spawner.global_transform.basis
	get_tree().get_root().add_child(bullet)
	resources.lose_stamina(15.0)


func update_bullet_target(reticle_point:Vector3):
	var spawn_loc = bullet_spawner.global_position
	target_direction = reticle_point
	bullet_spawner.look_at(reticle_point)


func force_overheat():
	current_move.try_force_move("overheat")
	ik_controller.override()


func take_damage():
	if current_move.is_vulnerable():
		resources.lose_health(5.0)
		player.send_sound("hit")
	else:
		print("not vulnerable, no damage taken")
