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

var current_lock_target : Targetable
var current_state : CameraState


var using_mouse_ctrl := false
@onready var camera_input: CameraInputGatherer = $Input

var available_targets : Array[Targetable]


@onready var states = {
	"locked" : $LockedCamera,
	"free" : $FreeCamera
}


func _ready():
	SignalBus.connect("TARGET_SCREEN_ENTERED",append_target)
	SignalBus.connect("TARGET_SCREEN_EXITED",erase_target)
	current_state = states["free"]
	current_state.Enter()


func _process(delta: float) -> void:
	var input = camera_input.gather_input()
	look_at = update_look_at()
	current_state.Update(input, look_at, delta)
	# each input package is a new array and so we have to free them or they just build up
	input.queue_free()

func _physics_process(delta: float) -> void:
	current_state.Physics_Update(look_at, delta)


func update_look_at():
	if look_at:
		print(look_at)
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


func find_target() -> Node3D:
	var possible_targets = get_tree().get_nodes_in_group("targetable")
	# loop through the list of targetable aspects
	for targetable in possible_targets:
		# get their position relative to the camera_mount(which is at the player location)
		var pos : Vector3 = camera_mount.global_position
		var otherpos : Vector3 = targetable.global_position
		var disq = pos.distance_squared_to(otherpos)
		# if that aspect is not in the camera view, discard it from the array
		if not camera.is_position_in_frustum(targetable.global_position):
			possible_targets.erase(targetable)
		# if the aspect is too far away, also discard it.
		if disq > 300.0:
			possible_targets.erase(targetable)
	# if, after we've sorted through that list, if there's anything left, get the first entry in the array.
	# we'll need a better system later, but this works for now.
	if not possible_targets.is_empty():
		return possible_targets[0]
	# if there are no valid targets after sorting through the list, then the result is null and thats ok
	return null


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
	else:
		if find_target() != null:
			reticle_point = find_target().global_position
		else:
			pass
	#reticle_debug.global_position = reticle_point
	update_reticle(reticle_point)
	return reticle_point


func update_reticle(reticle_point: Vector3):
	if not reticle_debug.global_position.is_equal_approx(reticle_point):
		reticle_debug.global_position = lerp(reticle_debug.global_position,reticle_point,1.25)
