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
		initial_state.Enter()
		current_state = initial_state
	print(states)
	
	
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(look_at, delta)
	find_reticle_point()


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(look_at, delta)

# func _input(event: InputEvent) -> void:
	# if event.is_action_pressed("Lock"):
		# current_lock_target = find_target()
		# if current_lock_target:
			# current_state.input_target_lock(event)
			
			

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	new_state.Enter()
	current_state = new_state

func find_target() -> Node3D:
	# find every node in the scene that can be targeted and store it as an array
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
