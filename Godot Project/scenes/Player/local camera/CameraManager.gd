extends Node
class_name CameraManager

@export var initial_state : CameraState
@export var look_at : Node3D
#var root_player : LocalPlayer

@onready var camera := $PlayerCamera
@onready var focus_point := $FocusPoint
@onready var camera_nest := $CameraNest
@onready var camera_mount := $CameraMount
@onready var ray_cast: RayCast3D = $CameraMount/RayCast3D

@onready var camera_focus: Node3D = $"../CameraFocus"

@onready var is_target_locked : bool = false
#@onready var target: Node3D = camera_nest

var current_lock_target : Targetable
var current_state : CameraState
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is CameraState:
			states[child.name.to_lower()] = child
# here, we connect the Transitioned signal from the child node. We don't have to do it manually this way.
			child.Transitioned.connect(on_child_transition)
# check if we set an initial state, and if we did, apply it.
	if initial_state:
		initial_state.Enter(current_lock_target)
		current_state = initial_state
	print(states)
	
# think of these funcs as kinda like piping Godot's process and physics_process funcs through to the child state
func _process(delta: float) -> void:
	gather_input()
	if current_state:
		current_state.Update(look_at, delta)
	#draw_debug_line()
	find_target()
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(look_at, delta)
		

func gather_input():
	var d_hor = Input.get_axis("Rstick_right","Rstick_left")
	var d_ver = Input.get_axis("Rstick_up","Rstick_down")
	current_state.input_axis_motion(d_hor,d_ver)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		current_lock_target = find_target()
		current_state.input_target_lock(event)

# this function receives transition signals from the state. This is how we handle transitioning between different
# states. It takes the name of the state that called it. "state" and the new state name that it wants to transition to.

func on_child_transition(state, new_state_name):
# check if the state calling the func is not the current state.
	if state != current_state:
		return
# get the reference to the new state from the dictionary
	var new_state = states.get(new_state_name.to_lower())
# make sure this new state we are getting exists
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
		#print(disq)
		if not camera.is_position_in_frustum(targetable.global_position):
			possible_targets.erase(targetable)
		if disq > 500.0:
			possible_targets.erase(targetable)
	if not possible_targets.is_empty():
		return possible_targets[0]
	return null
				
