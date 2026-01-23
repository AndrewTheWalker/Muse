extends CameraState
class_name FreeCameraState

@onready var local_camera: CameraModel = $".."

@onready var camera: Camera3D = $"../PlayerCamera"
@onready var focus_point: Node3D = $"../FocusPoint"
@onready var camera_nest: Node3D = $"../CameraNest"
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var shape_cast: ShapeCast3D = $"../CameraMount/ShapeCast3D"

@onready var camera_focus: Node3D = $"../../CameraFocus"

@onready var camera_input: CameraInputGatherer = $"../Input"

var hor_sense := 4.0
var ver_sense := 3.0
var offset := Vector3(0.0,0.75,4.5)
var buffer_radius = 0.2

func Enter():
	var shape = shape_cast.get_shape()
	shape.radius=buffer_radius
	print("entered free state")
	local_camera.is_target_locked = false


func Exit():
	pass


func Update(look_at:Node3D, delta: float) -> void:
	var input = camera_input.gather_input()
	input_axis_motion(input)
	move_focus_point(look_at)
	move_camera_nest(look_at)
	move_shapecast()
	move_camera()
	input.queue_free()

func move_focus_point(look_at: Node3D):
	if not focus_point.global_position.is_equal_approx(look_at.global_position):
		var new_focus = lerp(focus_point.global_position, look_at.global_position, 0.1)
		rotate_offset(new_focus)
		focus_point.global_position = new_focus


func move_camera_nest(look_at: Node3D):
	camera_mount.global_position = lerp(camera_mount.global_position, look_at.global_position, 0.1)
	if not shape_cast.is_colliding():
		camera_nest.global_position = lerp(camera_nest.global_position,camera_mount.global_position+offset,0.25)
	else:
		var new_point : Vector3 = calculate_shapecast_offset()
		camera_nest.global_position = lerp(camera_nest.global_position,new_point,0.1)


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


func input_axis_motion(input:InputPackage)->Vector3:
	var input_direction = Vector2(input.r_input_direction.x, input.r_input_direction.y).normalized()
	
	var d_hor = input_direction.x
	var d_ver = input_direction.y

	offset = offset.rotated(Vector3.UP, d_hor * hor_sense/100)
	var axis : Vector3 = offset.cross(Vector3.UP).normalized()
	var angle = d_ver * ver_sense/100
	var new_offset = offset.rotated(axis,angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	if new_offset_angle > 0.3 and new_offset_angle < 2.5:
		offset = offset.rotated(axis,angle)
	return offset


func calculate_shapecast_offset()->Vector3:
	# up in the update function I set the shapecast's target position equal to offset.
	
	var collision_point = shape_cast.get_collision_point(0)
	# buffer radius is equal to the shapecast sphere shape radius
	var collision_normal = (shape_cast.get_collision_normal(0))*buffer_radius
	var new_point = collision_point+collision_normal
	return(new_point)
