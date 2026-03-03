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
@export var tracking_angular_speed : float

@export var stamina_cost : float = 0

@onready var combos : Array[Combo] 

var enter_state_time : float
var initial_position : Vector3
var frame_length = 0.016

var has_queued_move : bool = false
var queued_move : String = "nonexistent queued move, error"

var has_forced_move : bool = false
var forced_move : String = "nonexistent forced move, error"


# where is DURATION set?
# answer: it is set inside the playerstates script. DURATION is equal the value of the backend animation length. 
var DURATION : float

func check_relevance(input : InputPackage) -> String:
	
	
	#if accepts_queueing():
		#check_combos(input)
	if accepts_queueing():
		check_queue(input)
	
	if has_queued_move and transitions_to_queued():
		try_force_move(queued_move)
		has_queued_move = false
	
	
	if has_forced_move:
		has_forced_move = false
		return forced_move
	
	return default_lifecycle(input)

# this is my own take on the input queueing system. We're going to check the move directly. 
# So, if move.queue_condition == true, then we'll run my version of check_combos.
# this is just the base function that will return false by default. But within each move (that I want to be queueable)
# I will have to specify conditions within this function

func queue_condition(input : InputPackage):
	return false
# this func should have a bunch of if statements I guess? Something along the lines of:
	#if input.actions.has("blahblah"):
		#if something something else:
			#return true/false


func check_queue(input : InputPackage):
	# in this func, we need to check if the move's queue conditions are true.
	# so we go through all the states in the container, and check if their queue condition is met.
	# if
	for move in container.get_children():
		if move is Move:
			if move.queue_condition(input) == true:
				has_queued_move = true
				queued_move = move.move_name
				print("queueing move: ",move.move_name)
				break


#func check_combos(input : InputPackage):
	#for combo : Combo in combos:
		#if combo.is_triggered(input) and resources.can_be_paid(container.moves[combo.triggered_move]):
			#has_queued_move = true
			#queued_move = combo.triggered_move


func best_input_that_can_be_paid(input : InputPackage) -> String:
	# in this function we sort through the current array of inputs (if there are any) and run some checks.
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
	input_direction.y = 0
	var face_direction = -(player.visuals.basis.z)
	face_direction.y = 0
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


func get_root_position_delta(delta_time : float) -> Vector3:
	return moves_data_repo.get_root_delta_pos(backend_animation, get_progress(), delta_time)

func can_shoot() -> bool:
	return moves_data_repo.get_can_shoot(backend_animation, get_progress())

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
	# commenting this for now because I don't have a staggered state.
	#if is_interruptable():
		#try_force_move("staggered")
	hit.queue_free()


func react_on_parry(_hit : HitData):
	try_force_move("parried")


func try_force_move(new_forced_move : String):
	if not has_forced_move:
		has_forced_move = true
		forced_move = new_forced_move
	elif container.moves[new_forced_move].priority >= container.moves[forced_move].priority:
		forced_move = new_forced_move
