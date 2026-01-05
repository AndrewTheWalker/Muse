extends Node
class_name Move

# all-move flags and variables here
var player : CharacterBody3D

# Important: Each move's animation string must match EXACTLY to the appropriate anim in the model.
var animation : String

# var animation_ended

# this base class has a priority list for all moves. When new input is processed, the new action is only valid
# if it's priority is higher than the present action. As you can see here, jump has a priority of 10, and run
# has a priority of 2. This means jumping action will always be allowed to overtake the running action, but not vice versa.
# declaring this var as static means all other nodes that extend this class have this dictionary accessible.
# the following function performs a simple array sorting algorithm to decide if the new input has priority.

# this functionality will also help when we implement input queueing later on... i think.
static var moves_priority : Dictionary = {
	"idle" : 1,
	"run" : 2,
	"sprint" : 3,
	"sprint_jump" : 10,
	"midair" : 10,
	"land" : 10,
	"sprint_land" : 10,
	"jump" : 10  # be generous to not edit this too much when sprint, dash, crouch etc are added
}

# note to self. If I ever choose to add a ready func here, know that it will be overridden by the
# individual move's ready funcs.

static func moves_priority_sort(a : String, b : String):
	if moves_priority[a] > moves_priority[b]:
		return true
	else:
		return false

# the default class check_relevance function prints this error, just in case we're calling it, rather than a proper state
func check_relevance(input : InputPackage) -> String:
	print_debug("error, implement the check_relevance function on your state")
	return "error, implement the check_relevance function on your state"

func update(input : InputPackage, delta : float):
	pass

func on_enter_state():
	pass

func on_exit_state():
	pass
