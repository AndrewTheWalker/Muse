extends CameraState
class_name LockedCameraState

''' NOTE TO SELF: At some point, please refactor somehow to have the camera check for a valid target before entering this state'''

const LERP_WEIGHT := 0.1
const OTHER_LERP_WEIGHT := 0.75

@onready var local_camera: CameraManager = $".."
@onready var free_camera: FreeCameraState = $"../FreeCamera"

@onready var camera: Camera3D = $"../PlayerCamera"
@onready var focus_point: Node3D = $"../FocusPoint"
@onready var camera_nest: Node3D = $"../CameraNest"
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var shape_cast: ShapeCast3D = $"../CameraMount/ShapeCast3D"

@onready var camera_focus: Node3D = $"../../CameraFocus"

var target : Targetable

var hor_sense := 4.0
var ver_sense := 3.0
var offset := Vector3(0.0,1.0,4.5)
var midpoint : Vector3
var buffer_radius = 0.2

func Enter():
	
	print("entered lock state")
	# CameraManager passes the target that it has found, if any, to this state. Then we change the 
	# camera's look_at to the target, if it wasn't already.
	# we do it here because if we got this far, we know for sure that everything checks out
	local_camera.is_target_locked = true
		
func Exit():
	pass

func Update(look_at:Node3D, delta: float) -> void:
	# locked camera differs in that it will automatically switch back to free cam if the target is lost.
	if look_at:
		calculate_midpoint(look_at)
		move_focus_point(look_at)
		move_camera_nest(look_at)
		move_shapecast()
		move_camera()
	else:
		drop_target()
	
func Physics_Update(look_at:Node3D, delta: float) -> void:
	pass
	
func calculate_midpoint(look_at:Node3D):
	# get the midpoint between the target and the player and focus the camera there. 
	# It just compositionally feels better than having the target always smack in the middle of the screen.
	var focus_pos = look_at.global_position
	var player_pos = camera_focus.global_position
	midpoint = (focus_pos + player_pos)*0.5
	
func move_focus_point(look_at: Node3D):
	# lerp the focus point to that new midpoint. then call this states version of rotate offset.
	var new_focus = lerp(focus_point.global_position, midpoint, OTHER_LERP_WEIGHT)
	rotate_offset_locked(new_focus)
	focus_point.global_position = new_focus
		
func move_camera_nest(look_at: Node3D):
	camera_mount.global_position = lerp(camera_mount.global_position, camera_focus.global_position, LERP_WEIGHT)
	if not shape_cast.is_colliding():
		camera_nest.global_position = lerp(camera_nest.global_position,camera_mount.global_position+offset,0.25)
	else:
		var new_point : Vector3 = calculate_shapecast_offset()
		camera_nest.global_position = lerp(camera_nest.global_position,new_point,0.1)
	
func move_camera():
	if not camera.position.is_equal_approx(camera_nest.position):
		camera.position = camera_nest.position
	camera.look_at(focus_point.global_position)	

func rotate_offset_locked(new_focus : Vector3):
	
	# I actually need to kinda rethink this one a bit because I forget exactly how it works...
	# the point of this is to always move the camera to keep the player and the target aligned.
	var new_focus_projected = new_focus
	new_focus_projected.y = 0.0
	var center_projected = camera_focus.global_position
	center_projected.y = 0.0
	var offset_xz_length = sqrt(offset.x * offset.x + offset.z * offset.z)
	var new_offset = (center_projected - new_focus_projected).normalized() * offset_xz_length
	new_offset.y = offset.y
	offset = new_offset
	
func input_target_lock(event: InputEvent):
	drop_target()

func move_shapecast():
	shape_cast.set_target_position(offset)
	
func calculate_shapecast_offset()->Vector3:	
	var collision_point = shape_cast.get_collision_point(0)
	var collision_normal = (shape_cast.get_collision_normal(0))*buffer_radius
	var new_point = collision_point+collision_normal
	return(new_point)

func drop_target():
	local_camera.look_at = camera_focus
	free_camera.offset = (camera_nest.global_position - camera_mount.global_position)
	local_camera.is_target_locked = false
	Transitioned.emit(self,"FreeCamera")
