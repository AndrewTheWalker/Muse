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


var available_targets = []
var target_index : int = 0

@onready var states = {
	"locked" : $LockedCamera,
	"free" : $FreeCamera
}


func _ready():
	SignalBus.connect("TARGET_SCREEN_ENTERED",append_target)
	SignalBus.connect("TARGET_SCREEN_EXITED",erase_target)
	look_at = camera_focus
	current_state = states["free"]
	current_state.Enter()


func _process(delta: float) -> void:
	look_at = check_look_at()
	current_state.Update(look_at, delta)


func _physics_process(delta: float) -> void:
	current_state.Physics_Update(look_at, delta)


func check_look_at():
	if look_at:
		return look_at
	else:
		look_at = camera_focus
		#current_state.drop_target()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		if current_state == states["locked"]:
			if available_targets.size() <= 1:
				if look_at != camera_focus:
					look_at = camera_focus
					is_target_locked = false
					switch_to("free")
		elif current_state == states["free"]:
			if not available_targets.is_empty():
				print(available_targets[0])
				switch_to("locked")
				is_target_locked = true
				look_at = available_targets[0]
			else:
				print("no targets")
	if event.is_action_pressed("Rstick_right"):
		if current_state == states["locked"]:
			if available_targets.size() > 1:
				cycle_target()
			else:
				print("not enough targets")

func switch_to(new_state : String):
	current_state.Exit()
	current_state = states[new_state]
	current_state.Enter()


func append_target(targetable):
	available_targets.append(targetable)
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)


func erase_target(targetable):
	available_targets.erase(targetable)
	print("erasing target")
	if available_targets.size() > 1:
		available_targets.sort_custom(sort_targets)


func sort_targets(a,b):
	# a and b represent the two targetables being evaluated in available_targets
	# we calcuclate the distance from the targetable to the focus point (i.e. the centre of the screen)
	# whichever one is closer, goes first in the order.
	var focus_pos = focus_point.global_position
	var dista = a.global_position.distance_squared_to(focus_pos)
	var distb = b.global_position.distance_squared_to(focus_pos)
	return dista < distb


func cycle_target():
	# this line allows us to cycle through the contents of available targets and loop back to the beginning
	# if we reach the end. The idea is that we use modulo, because if the result of target_index+1 is 
	# less than available_targets.size, the modulo is just the same number. But if it is equal to 
	# available targets.size, the result is 0, which is conveniently the first index entry.
	# neat!
	var new_index = (target_index+1) % available_targets.size()
	
	target_index = new_index
	print(new_index)
	look_at = available_targets[new_index]

func find_reticle_point()-> Vector3:
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
		if look_at:
			reticle_point = look_at.global_position
		else:
			print("error, can't find reticle point")
	reticle_debug.global_position = reticle_point
	update_reticle(reticle_point)
	return reticle_point


func update_reticle(reticle_point: Vector3):
	if not reticle_debug.global_position.is_equal_approx(reticle_point):
		reticle_debug.global_position = lerp(reticle_debug.global_position,reticle_point,1.25)
