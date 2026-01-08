extends Node
class_name CameraManager

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
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is CameraState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.Enter(current_lock_target)
		current_state = initial_state
	print(states)
	
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(look_at, delta)
	find_target()
	adjust_reticle()
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(look_at, delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		current_lock_target = find_target()
		current_state.input_target_lock(event)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	new_state.Enter(current_lock_target)
	current_state = new_state

func find_target() -> Node3D:
	var possible_targets = get_tree().get_nodes_in_group("targetable")
	for targetable in possible_targets:
		var pos : Vector3 = camera_mount.global_position
		var otherpos : Vector3 = targetable.global_position
		var disq = pos.distance_squared_to(otherpos)
		if not camera.is_position_in_frustum(targetable.global_position):
			possible_targets.erase(targetable)
		if disq > 300.0:
			possible_targets.erase(targetable)
	if not possible_targets.is_empty():
		return possible_targets[0]
	return null

func adjust_reticle()-> Vector3:
	reticle_debug.look_at(camera_nest.global_position, Vector3(0.0,0.1,0.0))
	var reticle_point : Vector3
	var default_point = reticle_locator.global_position
	if reticle_raycast.is_colliding():
		var collision_point = reticle_raycast.get_collision_point()
		reticle_point = collision_point
	else:
		reticle_point = default_point
	reticle_debug.global_position = reticle_point
	return reticle_point
	
