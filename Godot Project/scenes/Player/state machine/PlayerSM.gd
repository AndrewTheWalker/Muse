extends Node
class_name PlayerStateMachine

@export var initial_state : MoveState

var current_state : MoveState
var states : Dictionary = {}

# this for loop will check all the children of the state machine node, and check if they are valid States.
# if they are valid, they will be added to the states dictionary.
# to_lower forces the child node's name to be read in lowercase, which we're doing to proactively mitigate
# any case sensitive issues. 
func _ready() -> void:
	for child in get_children():
		if child is MoveState:
			states[child.name.to_lower()] = child
# here, we connect the Transitioned signal from the child node. We don't have to do it manually this way.
			child.Transitioned.connect(on_child_transition)
# check if we set an initial state, and if we did, apply it.
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
	print(states)

# think of these funcs as kinda like piping Godot's process and physics_process funcs through to the child state
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)
		

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
		
	new_state.Enter()
	
	current_state = new_state
