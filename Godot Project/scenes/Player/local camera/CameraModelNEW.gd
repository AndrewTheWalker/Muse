extends Node

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


func _ready():
	look_at = camera_focus

# check if look_at is valid before calling the state's update
func _process(delta: float) -> void:
	look_at = check_look_at()


func check_look_at():
	if look_at:
		return look_at
	else:
		look_at = camera_focus
		#current_state.drop_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		is_target_locked = true
	else:
		is_target_locked = false


func find_reticle_point()-> Vector3:
	# reticle_debug is a CSG mesh, so we have one line to make it face the camera. 
	# I am not using Vector3.UP as the second argument because it returns a colinear error.
	# this error does not actually affect functionality, but it is annoying. Therefore I am using
	# a custom vector.
	# this will also eventually be replaced with a GUI element positioned using camera.unproject_position
	reticle_debug.look_at(camera_nest.global_position, Vector3(0.0,0.1,0.0))
	
	# reticle_point is the vector3 representing where the reticle exists in 3D space.
	# default_point is the location of a node called "reticle locator" 
	# reticle locator is a Node3D which I have hand placed in the camera scene
	# the reticle is slightly above the true line of sight, which frames things nicely.
	# a big consideration in this is also that the reticle is where the player's bullets try to aim towards
	
	var reticle_point : Vector3
	var default_point = reticle_locator.global_position
	
	# reticle raycast is a ray from the camera itself to reticle point. 
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
