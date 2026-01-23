extends Node
class_name CameraModel


@export var initial_state : CameraState
@export var look_at : Node3D

@onready var camera := $PlayerCamera
@onready var focus_point := $FocusPoint
@onready var camera_nest := $CameraNest
@onready var camera_mount := $CameraMount

@onready var reticle_debug = $"ReticleDebug"
@onready var reticle_raycast: RayCast3D = $PlayerCamera/ReticleRaycast
@onready var reticle_locator: Node3D = $PlayerCamera/reticle_locator
@onready var camera_focus: Node3D = $"../CameraFocus"

@onready var is_target_locked : bool = false

var current_lock_target : Node3D
var current_state : CameraState


var available_targets = []


@onready var states = {
	"locked" : $LockedCamera,
	"free" : $FreeCamera
}


func _ready():
	SignalBus.connect("TARGET_SCREEN_ENTERED",append_target)
	SignalBus.connect("TARGET_SCREEN_EXITED",erase_target)
	look_at = camera_focus
	current_state = states["free"]
	current_state.Enter()


func _process(delta: float) -> void:
	look_at = update_look_at()
	current_state.Update(look_at, delta)


func _physics_process(delta: float) -> void:
	current_state.Physics_Update(look_at, delta)


func update_look_at():
	if look_at:
		return look_at
	else:
		look_at = camera_focus


func switch_to(new_state : String):
	current_state.Exit()
	current_state = states[new_state]
	current_state.Enter()


func append_target(targetable):
	available_targets.append(targetable)
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)


func erase_target(targetable):
	available_targets.erase(targetable)
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)


func sort_targets(a,b):
	# a and b represent the two targetables being evaluated in available_targets
	# we calcuclate the distance from the targetable to the focus point (i.e. the centre of the screen)
	# whichever one is closer, goes first in the order.
	var focus_pos = focus_point.global_position
	var dista = a.global_position.distance_squared_to(focus_pos)
	var distb = b.global_position.distance_squared_to(focus_pos)
	return dista < distb



func find_reticle_point():#-> Vector3:
	reticle_debug.look_at(camera_nest.global_position, Vector3(0.0,0.1,0.0))
	var reticle_point : Vector3
	var default_point = reticle_locator.global_position
	if !is_target_locked:
		if reticle_raycast.is_colliding():
			var collision_point = reticle_raycast.get_collision_point()
			reticle_point = collision_point
		else:
			reticle_point = default_point
	#else:
		#if find_target() != null:
			#reticle_point = find_target().global_position
		#else:
			#pass
	#reticle_debug.global_position = reticle_point
	update_reticle(reticle_point)
	return reticle_point


func update_reticle(reticle_point: Vector3):
	if not reticle_debug.global_position.is_equal_approx(reticle_point):
		reticle_debug.global_position = lerp(reticle_debug.global_position,reticle_point,1.25)
