extends Node
class_name Move


var player : CharacterBody3D
var skeleton : Skeleton3D
var animator : Node
var resources : PlayerResources
var combat : Combat
var moves_data_repo : MovesDataRepository
var container : PlayerStates
var area_awareness : AreaAwareness


@export var animation : String
@export var move_name : String
@export var priority : int
@export var backend_animation : String
@export var tracking_angular_speed : float = 45

@export var stamina_cost : float = 0

@onready var combos : Array[Combo] 

var enter_state_time : float
var initial_position : Vector3
var frame_length = 0.016

var has_queued_move : bool = false
var queued_move : String = "nonexistent queued move, drop error please"

var has_forced_move : bool = false
var forced_move : String = "nonexistent forced move, drop error please"


#where is DURATION set?
var DURATION : float

func check_relevance(input : InputPackage) -> String:
	# here we are in check relevance. It will do a few things.
	
	# first, does this move accept queueing? If so, check the queue!
	if accepts_queueing():
		check_combos(input)
	
	# if it does have a queued move, and transitiones_to_queued is true, then we try to switch it to that queued move.
	# "transitions_to_queued" references the parameter animation track, which essentially checks how far the animation has progressed.
	# if it has progressed to the point where queued moves are now permitted, THEN we force the move.
	# we don't want the queued move to happen immediately, and this prevents that.
	if has_queued_move and transitions_to_queued():
		try_force_move(queued_move)
		has_queued_move = false
	
	# similarly, does it have a forced move? has the player been hit? are they dead? if so, then we force that change.
	if has_forced_move:
		has_forced_move = false
		return forced_move
	
	# if none of those things apply, then we go with the move's default behaviour and let it ride out whatever it is that it wants to do,.
	return default_lifecycle(input)


func check_combos(input : InputPackage):
	for combo : Combo in combos:
		if combo.is_triggered(input) and resources.can_be_paid(container.moves[combo.triggered_move]):
			has_queued_move = true
			queued_move = combo.triggered_move


func best_input_that_can_be_paid(input : InputPackage) -> String:
	# now, in this function we sort through the current array of inputs (if there are any) and run some checks.
	# can the move be performed given the current state of resources? i.e. do you have the stamina to do this?
	# and are we already doing this move?
	# if so, return okay which means, keep doing what you're doing
	# if not, we FINALLY have checked everything and made sure we are returning the best possible action.
	input.actions.sort_custom(container.moves_priority_sort)
	for action in input.actions:
		if resources.can_be_paid(container.moves[action]):
			if container.moves[action] == self:
				return "okay"
			else:
				return action
				
	return "ERROR because for some reason input.actions doesn't contain even idle"  


func _update(input : InputPackage, delta : float):
	update_resources(delta)
	if tracks_input_vector():
		process_input_vector(input, delta)
	update(input, delta)

func update(_input : InputPackage, _delta : float):
	pass

func process_input_vector(input : InputPackage, delta : float):
	var input_direction = (player.camera.basis * Vector3(input.l_input_direction.x, 0, -input.l_input_direction.y)).normalized()
	var face_direction = -(player.visuals.basis.z)
	var angle = face_direction.signed_angle_to(input_direction, Vector3.UP)
	
	#player.rotate_y(clamp(angle, -tracking_angular_speed * delta, tracking_angular_speed * delta))

func update_resources(delta : float):
	resources.update(delta)


func mark_enter_state():
	enter_state_time = Time.get_unix_time_from_system()


func get_progress() -> float:
	var now = Time.get_unix_time_from_system()
	return now - enter_state_time


func works_longer_than(time : float) -> bool:
	if get_progress() >= time:
		return true
	return false


func works_less_than(time : float) -> bool:
	if get_progress() < time: 
		return true
	return false


func works_between(start : float, finish : float) -> bool:
	var progress = get_progress()
	if progress >= start and progress <= finish:
		return true
	return false


func transitions_to_queued() -> bool:
	return moves_data_repo.get_transitions_to_queued(backend_animation, get_progress())

func accepts_queueing() -> bool:
	return moves_data_repo.get_accepts_queueing(backend_animation, get_progress())

func tracks_input_vector() -> bool:
	return moves_data_repo.tracks_input_vector(backend_animation, get_progress())

func accepts_tracking_direction() -> bool:
	return moves_data_repo.accepts_tracking_direction(backend_animation, get_progress())

func is_vulnerable() -> bool:
	return moves_data_repo.get_vulnerable(backend_animation, get_progress())

func is_interruptable() -> bool:
	return moves_data_repo.get_interruptable(backend_animation, get_progress())

#func is_parryable() -> bool:
	#return moves_data_repo.get_parryable(backend_animation, get_progress())

func get_root_position_delta(delta_time : float) -> Vector3:
	return moves_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta_time)

#func right_weapon_hurts() -> bool:
	#return moves_data_repo.get_right_weapon_hurts(backend_animation, get_progress())

# "default-default", works for animations that just linger

func default_lifecycle(input : InputPackage):
	# in the default lifecycle function we basically just check how long the animation has progressed.
	# works_longer_than will get unix time and subtract the timestamp of when the state began.
	# if that difference is longer than the given DURATION of the animation, then we return "best_input_that_can_be_paid" which essentially means "the next most relevant move, given the circumstances."
	# otherwise, if we haven't reached the duration yet, we return okay.
	if works_longer_than(DURATION):
		return best_input_that_can_be_paid(input)
	return "okay"


func base_on_enter_state():
	initial_position = player.global_position
	#resources.pay_resource_cost(self)
	mark_enter_state()
	on_enter_state()


func on_enter_state():
	pass


func base_on_exit_state():
	on_exit_state()


func on_exit_state():
	pass


func assign_combos():
	for child in get_children():
		if child is Combo:
			combos.append(child)
			child.move = self


# Gabs script calls for weapons, but I call for Bullets. Any instance of "Weapon" is replaced with "Bullet" for me. 
func form_hit_data(_bullet : Bullet) -> HitData:
	print("someone tries to get hit by default Move")
	return HitData.blank()


func react_on_hit(hit : HitData):
	if is_vulnerable():
		resources.lose_health(hit.damage)
	if is_interruptable():
		try_force_move("staggered")
	hit.queue_free()


func react_on_parry(_hit : HitData):
	try_force_move("parried")


func try_force_move(new_forced_move : String):
	if not has_forced_move:
		has_forced_move = true
		forced_move = new_forced_move
	elif container.moves[new_forced_move].priority >= container.moves[forced_move].priority:
		forced_move = new_forced_move
