extends CameraState
class_name FreeCameraState

@onready var local_camera: CameraManager = $".."

@onready var camera: Camera3D = $"../PlayerCamera"
@onready var focus_point: Node3D = $"../FocusPoint"
@onready var camera_nest: Node3D = $"../CameraNest"
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var shape_cast: RayCast3D = $"../CameraMount/ShapeCast3D"

@onready var camera_focus: Node3D = $"../../CameraFocus"

var hor_sense := 4.0
var ver_sense := 3.0
var offset := Vector3(0.0,0.5,4.5)


func Enter(current_lock_target: Node3D):
	print("entered free state")
	'if local_camera.look_at != camera_focus:
		print("works so far")
		local_camera.look_at = camera_focus'
		
func Exit():
	pass

func Update(look_at:Node3D, delta: float) -> void:
	move_focus_point(look_at)
	move_camera_nest(look_at)
	move_shapecast()
	move_camera()
	
func Physics_Update(look_at:Node3D, delta: float) -> void:
	pass

func move_focus_point(look_at: Node3D):
	if not focus_point.global_position.is_equal_approx(look_at.global_position):
		var new_focus = lerp(focus_point.global_position, look_at.global_position, 0.1)
		rotate_offset(new_focus)
		focus_point.global_position = new_focus
		
func move_camera_nest(look_at: Node3D):
	camera_mount.global_position = lerp(camera_mount.global_position, look_at.global_position, 0.1)
	if not shape_cast.is_colliding():
		#camera_nest.global_position = camera_mount.global_position+offset
		camera_nest.global_position = lerp(camera_nest.global_position,camera_mount.global_position+offset,0.25)
	else:
		var collider = shape_cast.get_collider()
		print(collider)
		var collision_point : Vector3 = shape_cast.get_collision_point()
		camera_nest.global_position = lerp(camera_nest.global_position,collision_point, 0.1)
func move_camera():
	if not camera.position.is_equal_approx(camera_nest.position):
		camera.position = camera_nest.position
	camera.look_at(focus_point.global_position)

func move_shapecast():
	shape_cast.set_target_position(offset)
	
func rotate_offset(new_focus : Vector3):
	var new_focus_projected = new_focus
	new_focus_projected.y = 0.0
	var old_offset_projected = -offset
	old_offset_projected.y = 0.0
	var center = focus_point.global_position+offset
	var center_projected = center
	center_projected.y = 0
	var new_direction = new_focus_projected - center_projected
	var alpha = new_direction.angle_to(old_offset_projected)
	
	var decider = new_direction.cross(old_offset_projected)
	if decider.y <0:
		offset = offset.rotated(Vector3.UP,alpha)
	else:
		offset = offset.rotated(Vector3.UP,-alpha)

func input_axis_motion(d_hor:float,d_ver:float)->Vector3:
	offset = offset.rotated(Vector3.UP, d_hor * hor_sense/100)
	
	var axis : Vector3 = offset.cross(Vector3.UP).normalized()
	var angle = d_ver * ver_sense/100
	var new_offset = offset.rotated(axis,angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	print(new_offset_angle)
	if new_offset_angle > 0.3 and new_offset_angle < 2.5:
		offset = offset.rotated(axis,angle)
	return offset
	
func shapecast_detection():
	if shape_cast.is_colliding():
		var collision_point : Vector3 = shape_cast.get_collision_point()

func input_target_lock(event: InputEvent):
	Transitioned.emit(self,"LockedCamera")
