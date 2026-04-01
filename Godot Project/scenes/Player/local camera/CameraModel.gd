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

@onready var input_gatherer : InputGatherer = $"../Input"


@onready var is_target_locked : bool = false

var current_state : CameraState
@onready var free_state :FreeCameraState = $FreeCamera

var available_targets = []
var target_index : int = 0

@onready var states = {
	"locked" : $LockedCamera,
	"free" : $FreeCamera
}


# connect to targetable aspect signals so we can append/erase targets from our available_target array
# by default, look_at is "camera_focus" which is the player's reference point for the camera
# we load in the free state by default, then enter it.
func _ready():
	SignalBus.connect("TARGET_SCREEN_ENTERED",append_target)
	SignalBus.connect("TARGET_SCREEN_EXITED",erase_target)
	look_at = camera_focus
	current_state = states["free"]
	current_state.Enter()

# check if look_at is valid before calling the state's update
func _process(delta: float) -> void:
	look_at = check_look_at()
	current_state.Update(look_at, delta)

## presently, the camera states do not have physics. 
	# The base class for the CameraState could use physics if we wanted, but for now, we're not calling it.
	# func _physics_process(delta: float) -> void:
		# current_state.Physics_Update(look_at, delta)


# we run this every frame. If at any point look_at_ is null, set look_at back to camera_focus
# it is important that we run this BEFORE calling the state's update.
func check_look_at():
	if look_at:
		return look_at
	else:
		look_at = camera_focus
		#current_state.drop_target()


## handle all camera related input. I experimented with a separate InputHandler class but it felt like overkill
	# This functionality seems satisfactory.
	# The resulting behaviour of this function is 
	# if the player presses L1, and the camera is currently free it finds a target and enters the locked state
	# if the player presses L1 and the camera is currently locked, then we release the lock.
	# if the player presses right stick input, we check if there are other targets available and if so, switch targets.
	# I plan to alter the array sorting algorithm in the future, so the player can cycle left or right using the right stick.

func _unhandled_input(event: InputEvent) -> void:
	
	## I have made it so that holding R simply stops camera rotation. 
	
	if event.is_action_pressed("Lock"):
		switch_to("locked")
	if event.is_action_released("Lock"):
		switch_to("free")
	
	
	## leaving all this here in case I wanna switch back
	#if event.is_action_pressed("Lock"):
		#if current_state == states["locked"]:
			#if available_targets.size() > 1:
				#cycle_target()
			#else:
				#print("not enough targets")
		#elif current_state == states["free"]:
			#if not available_targets.is_empty():
				#switch_to("locked")
				#is_target_locked = true
				#look_at = available_targets[0]
				#SignalBus.TARGET_LOCKED.emit(look_at)
			#else:
				#print("no targets")
	#if event.is_action_pressed("Rstick_down"):
		#if current_state == states["locked"]:
			#current_state.drop_target()
		#else:
			#print("no target right now")



# simple function to switch states.
func switch_to(new_state : String):
	current_state.Exit()
	current_state = states[new_state]
	current_state.Enter()

# called when targetable enters the view
func append_target(targetable):
	available_targets.append(targetable)
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)

# called when targetable exits the view
func erase_target(targetable):
	available_targets.erase(targetable)
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)


'''at some point in the future, I must write a new algorithm that sorts by left/right instead of distance'''
func sort_targets(a,b):
	# a and b represent the two targetables being evaluated in available_targets
	# we calcuclate the distance from the targetable to the focus point (i.e. the centre of the screen)
	# whichever one is closer, goes first in the order.
	var focus_pos = focus_point.global_position
	var dista = a.global_position.distance_squared_to(focus_pos)
	var distb = b.global_position.distance_squared_to(focus_pos)
	return dista < distb


func cycle_target():
	## this line allows us to cycle through the contents of available targets and loop back to the beginning
		# if we reach the end. The idea is that we use modulo, because if the result of target_index+1 is 
		# less than available_targets.size, the modulo is just the same number. But if it is equal to 
		# available targets.size, the result is 0, which is conveniently the first index entry.
		# neat!
	var new_index = (target_index+1) % available_targets.size()
	
	target_index = new_index
	look_at = available_targets[new_index]


func find_reticle_point()-> Vector3:
	## reticle_debug is a CSG mesh, so we have one line to make it face the camera. 
		# I am not using Vector3.UP as the second argument because it returns a colinear error.
		# this error does not actually affect functionality, but it is annoying. Therefore I am using
		# a custom vector.
		# this will also eventually be replaced with a GUI element positioned using camera.unproject_position
	reticle_debug.look_at(camera_nest.global_position, Vector3(0.0,0.1,0.0))
	
	## reticle_point is the vector3 representing where the reticle exists in 3D space.
		# default_point is the location of a node called "reticle locator" 
		# reticle locator is a Node3D which I have hand placed in the camera scene
		# the reticle is slightly above the true line of sight, which frames things nicely.
		# a big consideration in this is also that the reticle is where the player's bullets try to aim towards
	
	var reticle_point : Vector3
	var default_point = reticle_locator.global_position
	
	## reticle raycast is a ray from the camera itself to reticle point. 
		# reticle point is also a particular distance away from the camera, so it only collides
		# with surfaces that are within that threshold.
		# we start by checking if we are NOT in locked mode. In this case, we either set the reticle
		# position to be at the collision point of the ray cast, or, if there is no such point, set it 
		# to the default position.
		# if we ARE in locked mode, then the reticle point remains fixed on the value of "look_at" 
		# if for some reason look_at is undefined, it prints an error. But logically, this should never happen.
	if !is_target_locked:
		if reticle_raycast.is_colliding():
			var collision_point = reticle_raycast.get_collision_point()
			reticle_point = collision_point
		else:
			reticle_point = default_point
	else:
		if look_at:
			reticle_point = look_at.global_position
		else:
			print("error, can't find reticle point")
			
	# after all that, we actually tell the visuals of the reticle to go to the point we found.
	reticle_debug.global_position = reticle_point
	update_reticle(reticle_point)
	
	# return the reticle_point. this has no use now, but it will once I implement the GUI
	return reticle_point

# simple func which lerps (or more accurately extrapolates) the reticle visuals to the new point
# if these positions are unequal
# this will be deprecated once the GUI is functional.
func update_reticle(reticle_point: Vector3):
	if not reticle_debug.global_position.is_equal_approx(reticle_point):
		reticle_debug.global_position = lerp(reticle_debug.global_position,reticle_point,1.0)


func get_unprojected_position()->Vector2:
	var position: Vector3
	var unprojected_position
	if reticle_raycast.is_colliding():
		position = reticle_raycast.get_collision_point()
		#print("reticle raycast is colliding, position is ", position)
	else:
		position = reticle_locator.global_position
		#print("reticle raycast is NOT colliding, position is ", position)
	unprojected_position = camera.unproject_position(position)
	#print("final unprojected position ", unprojected_position)
	return unprojected_position
	
func get_projected_position()->Vector3:
	var position: Vector3
	position = reticle_locator.global_position
	return position
	
