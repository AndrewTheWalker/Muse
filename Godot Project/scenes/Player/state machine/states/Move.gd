extends Node
class_name Move

# all-move flags and variables here
var player : CharacterBody3D

# Important: Each move's animation string must match EXACTLY to the appropriate anim in the model.
# It's not gonna autofill for you.
var animation : String
# the following vars have to do with combos. I am including them for now but they may not be needed
var move_name : String
var has_queued_move : bool = false
var queued_move : String = "none, drop error please"

# a var to store the moment in time when the state transitions. Needed for sustained time states like jump.
var enter_state_time : float

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
	"sprintjump" : 10,
	"midair" : 10,
	"land" : 10,
	"sprintland" : 10,
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

# the following funcs all have to do with caluclating state time
# we can call them if/when we need them.
# note to self: the else: line is implied, based on the indentation.

# get the moment in time that the transition happened
func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()

# get the current moment relative to enter_state_time
func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time

# the following three functions are simple ways for us to check new moves against time later.
# each move will have a predefined constant for this function to check. 
# these time constants will be determined by the animation
func works_longer_than(time: float) -> bool:
	if get_progress() >= time:
		return true
	return false
	
func works_less_than(time: float) -> bool:
	if get_progress() < time:
		return true
	return false
	
func works_between(start: float, finish: float) -> bool:
	var progress = get_progress()
	if progress >= start and progress <= finish:
		return true
	return false
	
	
	
	
# General Moves heir usage guide.

# > check_relevance function aims to be short and simple.
# 	Its general structure is as follows: 
#	if (move is ready to transition) :
#		transition to the highest priority out there
#	else:
#		return "okay" to save our managing status.
#
# 	Move readyness for transition is generally a simple function based on timings or statuses of the player.
#	If you are starting to understand that your transition readyness is a complex method, OR
# 	if you are tempted to add third branching operator into your check_relevance function,
#	seriously consider if Combo can do this logic for you, you won't regret its usage I promise.
#	(Combo is clickable even from comments btw)

# > update functions manages perframe behaviour of your Move.
#	There are two update types: constant change and a single dynamic update on some timing.
#	To implement simple constant changes, try to find some physics abstraction for them to make
#	engine work for you. If your constant changes are too complex, try to avoid hardcoding 
#	the behaviour into a giant update, better shove the changes data into a backend animation or
#	some other data structure resource.
#	To implement timed changes, use a flag and work with timings via get_progress() and Co.
#	To roughly base your internal timings on the players behaviour, you can check skeleton
#	animation for reference. But for the love of god please avoid referensing skeleton and animator
#	in any shape way or form in the Moves code directly. This way your Move "backend" is free from
#	thousand different ways someone (probably you from the future) can mess up your skeleton, scene composition,
#	animations, names libraries etc.
