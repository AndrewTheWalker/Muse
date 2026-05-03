extends CameraState
class_name StableCameraState

@onready var local_camera: CameraModel = $".."
@onready var free_camera: FreeCameraState = $"../FreeCamera"

@onready var camera: Camera3D = $"../PlayerCamera"
@onready var focus_point: Node3D = $"../FocusPoint"
@onready var camera_nest: Node3D = $"../CameraNest"
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var shape_cast: ShapeCast3D = $"../CameraMount/ShapeCast3D"
@onready var camera_timer: Timer = $"../CameraTimer"

@onready var camera_focus: Node3D = $"../../CameraFocus"

@onready var cone_finder: ConeFinder = $"../ConeFinder"

@export var max_slowdown : float = 0.6 #value should be between 0 and 1

var is_shooting := false

var h_inv := -1
var v_inv := -1

@export var sensitivity_multiplier : float = 1.0
var hor_sense := 2.0
var ver_sense := 1.0
var offset := Vector3(0.0,0.75,5.5)
var buffer_radius = 0.2


# here in the free camera state, we begin by defining a shapecast. which is a child of the mount.
# this shapecast will function like a spring arm.
# why not use an actual spring arm? I have a good reason. Wait and see...
# we also tell the CameraModel that target_locked is false
# the only time this should actually be true is if we are in this state, so that's why it's done here.

func Enter():
	var shape = shape_cast.get_shape()
	shape.radius=buffer_radius
	local_camera.is_target_locked = false
	if ! SignalBus.is_connected("INVERT_SIGNAL",set_inverse):
		SignalBus.connect("INVERT_SIGNAL",set_inverse)
	if ! SignalBus.is_connected("ADJUST_HSENS",set_sensitivity_h):
		SignalBus.connect("ADJUST_HSENS",set_sensitivity_h)
	if ! SignalBus.is_connected("ADJUST_VSENS",set_sensitivity_v):
		SignalBus.connect("ADJUST_VSENS",set_sensitivity_v)
	cone_finder.set_process(true)


func set_inverse(button: String):
	if button == "h_down":
		h_inv = 1
	if button == "h_up":
		h_inv = -1
	if button == "v_down":
		v_inv = 1
	if button == "v_up":
		v_inv = -1


func set_sensitivity_h(new_value: float):
	var current_h_sense = hor_sense
	var new_h_sense = new_value * 0.2
	hor_sense = new_h_sense


func set_sensitivity_v(new_value: float):
	var current_v_sense = ver_sense
	var new_v_sense = new_value * 0.1
	ver_sense = new_v_sense


# so, to demystify this a little...
# the entirety of the camera system is held up by two big beautiful values.
# The first is a vector3 called "offset" which defines the camera's location in global space relative to the player. 
# The second is the node3D called "look_at" which defines the point in space the cameara looks at.
# Look_at is entirely handles by the CameraManager, and offset is handled by the states.

# offset is, by default a value handpicked by me, which I feel frames everything nicely. 

# we have a lovely row of functions in update, all of which serve the purpose of moving/framing everything in a pleasing way.
func Update(look_at:Node3D, delta: float) -> void:
	input_axis_motion()
	move_focus_point(look_at)
	move_camera_nest(look_at)
	move_shapecast()
	move_camera()


# first step, check for player input. the X and Y axis of the right stick are set to have different sensitivity values
# i will eventually add options for the player to adjust sensitivity, and to invert the input.
# this is why the values hor_sense and ver_sense are divided by 100 and multiplied by -1
# hor_sense and ver_sense are nice integers that will be easy for the player to understand when they change the option.
# -1 is there because I like inverted controls, but this will be replaced with a var that can also be +1 later.

func input_axis_motion()->Vector3:

	var input_direction = Input.get_vector("Rstick_left","Rstick_right","Rstick_down","Rstick_up").limit_length()
	
	var d_hor = input_direction.x
	var d_ver = input_direction.y

	var aim_assist_modifier = cone_finder.aim_assist_strength_value

	offset = offset.rotated(Vector3.UP, (d_hor * hor_sense/100 * h_inv)*(sensitivity_multiplier * (1-aim_assist_modifier*max_slowdown)))
	
	var axis : Vector3 = offset.cross(Vector3.UP).normalized()
	
	var angle = (d_ver * ver_sense/100 * v_inv)*(sensitivity_multiplier * (1-aim_assist_modifier*max_slowdown))

	var new_offset = offset.rotated(axis,angle)

	var new_offset_angle = new_offset.angle_to(Vector3.UP)

	# limit the amount that the angle can go to prevent going over the player's head or under the floor.

	if new_offset_angle > 0.3 and new_offset_angle < 2.5:
		offset = offset.rotated(axis,angle)
	return offset


func move_focus_point(look_at: Node3D):
	## 
	#in locked mode, we actually want to look a little bit up, so we get a vector 3 that's slightly above look_at
	var look_at_locked = look_at.global_position + Vector3(0.0,0.3,0.0)
	if not focus_point.global_position.is_equal_approx(look_at_locked):
		var new_focus = lerp(focus_point.global_position, look_at_locked, 0.25)
		focus_point.global_position = new_focus


func move_camera_nest(look_at: Node3D):
	camera_mount.global_position = lerp(camera_mount.global_position, look_at.global_position, 0.5)
	if not shape_cast.is_colliding():
		camera_nest.global_position = lerp(camera_nest.global_position,camera_mount.global_position+offset,0.5)
	else:
		var new_point : Vector3 = calculate_shapecast_offset()
		camera_nest.global_position = lerp(camera_nest.global_position,new_point,0.5)


func move_camera():
	if not camera.position.is_equal_approx(camera_nest.position):
		camera.position = camera_nest.position
	camera.look_at(focus_point.global_position)


func move_shapecast():
	shape_cast.set_target_position(offset)


func calculate_shapecast_offset()->Vector3:
	# up in the update function I set the shapecast's target position equal to offset.
	
	var collision_point = shape_cast.get_collision_point(0)
	# buffer radius is equal to the shapecast sphere shape radius
	var collision_normal = (shape_cast.get_collision_normal(0))*buffer_radius
	var new_point = collision_point+collision_normal
	return(new_point)


func Exit():
	var offset_direction : Vector3 = camera_mount.global_position.direction_to(camera_nest.global_position)
	var rotation_to_align = Quaternion(offset_direction.normalized(),free_camera.offset.normalized())
	free_camera.offset = free_camera.offset * rotation_to_align
	cone_finder.set_process(false)
