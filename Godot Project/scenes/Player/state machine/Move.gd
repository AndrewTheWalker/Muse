extends Node
class_name MoveOld


var player : CharacterBody3D

var animation : String
var move_name : String
var has_queued_move : bool = false
var queued_move : String = "none, drop error please"

var enter_state_time : float


static var moves_priority : Dictionary = {
	"idle" : 1,
	"run" : 2,
	"sprint" : 3,
	"roll" : 9,
	"sprintjump" : 10,
	"midair" : 10,
	"land" : 10,
	"sprintland" : 10,
	"jump" : 10  # be generous to not edit this too much when sprint, dash, crouch etc are added
}


static func moves_priority_sort(a : String, b : String):
	if moves_priority[a] > moves_priority[b]:
		return true
	else:
		return false


func check_relevance(input : InputPackage) -> String:
	print_debug("error, implement the check_relevance function on your state")
	return "error, implement the check_relevance function on your state"


func update(input : InputPackage, delta : float):
	pass


func on_enter_state():
	pass


func on_exit_state():
	pass


func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()


func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time


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
