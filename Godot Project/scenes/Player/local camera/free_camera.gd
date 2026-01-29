extends CameraState
class_name FreeCameraState

@onready var local_camera: CameraModel = $".."

@onready var camera: Camera3D = $"../PlayerCamera"
@onready var focus_point: Node3D = $"../FocusPoint"
@onready var camera_nest: Node3D = $"../CameraNest"
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var shape_cast: ShapeCast3D = $"../CameraMount/ShapeCast3D"
@onready var timer: Timer = $"../Timer"

@onready var camera_focus: Node3D = $"../../CameraFocus"

var is_shooting := false

var h_inv := -1
var v_inv := -1

var hor_sense := 2.0
var ver_sense := 1.0
var offset := Vector3(0.0,0.75,4.5)
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
	SignalBus.connect("INVERT_SIGNAL",set_inverse)

func set_inverse(button: String):
	if button == "h_down":
		h_inv = 1
	if button == "h_up":
		h_inv = -1
	if button == "v_down":
		v_inv = 1
	if button == "v_up":
		v_inv = -1
func Exit():
	pass

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
	var input_direction = Input.get_vector("Rstick_left","Rstick_right","Rstick_down","Rstick_up").normalized()
	
	var d_hor = input_direction.x
	var d_ver = input_direction.y

	offset = offset.rotated(Vector3.UP, d_hor * hor_sense/100 * h_inv)
	var axis : Vector3 = offset.cross(Vector3.UP).normalized()
	var angle = d_ver * ver_sense/100 * v_inv
	var new_offset = offset.rotated(axis,angle)
	var new_offset_angle = new_offset.angle_to(Vector3.UP)
	# limit the amount that the angle can go to prevent going over the player's head or under the floor.
	if new_offset_angle > 0.3 and new_offset_angle < 2.5:
		offset = offset.rotated(axis,angle)
	return offset


# focus_point is the node3D which the camera actually looks at.
# focus_point never changes, but look_at does.
# take note that we check if the player is currently shooting, that will come up later.
func move_focus_point(look_at: Node3D):
	if not focus_point.global_position.is_equal_approx(look_at.global_position):
		var new_focus = lerp(focus_point.global_position, look_at.global_position, 0.1)
		if !is_shooting:
			rotate_offset(new_focus)
		focus_point.global_position = new_focus


# camera_nest is another Node3D that represents a position that the camera is trying to catch up to every frame.
# this is where we check for the shapecast collision.
# the purpose of the camera_nest is to allow smooth position adjustment. If we moved the camera directly, it feels jerky.
func move_camera_nest(look_at: Node3D):
	camera_mount.global_position = lerp(camera_mount.global_position, look_at.global_position, 0.1)
	if not shape_cast.is_colliding():
		camera_nest.global_position = lerp(camera_nest.global_position,camera_mount.global_position+offset,0.25)
	else:
		var new_point : Vector3 = calculate_shapecast_offset()
		camera_nest.global_position = lerp(camera_nest.global_position,new_point,0.1)

# once the camera_nest finds its place, we move the camera itself.
func move_camera():
	if not camera.position.is_equal_approx(camera_nest.position):
		camera.position = camera_nest.position
	camera.look_at(focus_point.global_position)


# the shapecast's target position is equal to the value of offset.
func move_shapecast():
	shape_cast.set_target_position(offset)


# this is the big one. This function is what allows the camera to gently "follow" the player. This is also the reason
# why I can't use a regular shapecast. A shapecast causes the camera's pivot point to be attached to the player, but in order
# to achieve the intended form of movement, the *player's* pivot point needs to be attached to the camera. But I still need
# the camera to avoid clipping through walls and other geometry. It's a bit hard to explain, but using a spring arm just "feels" bad.
# how it works is not as important as "why" it works.

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


# a simple function that switches a boolean, but it does an extremely important job.
# if the player is shooting, the camera needs to stop rotating. This is critical to allowing the player to properly aim.
# without it, the camera's adjustment makes it "appear" that the bullets are drifting off to the side, when in reality they are
# travelling straight as intended, but the perspective has changed while the bullet is in flight.
# implementing the timer is a behaviour I copied from Splatoon. It waits for a second in case the player would like to shoot again,
# if they haven't tried to shoot again in that time, we go back to default behaviour.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		is_shooting = true
	if event.is_action_released("Shoot"):
		timer.start()
		await timer.timeout
		is_shooting = false



# this little function gently nudges the shapecast away from surfaces. 
# Without it, it is still possible for the camera to clip through geometry.
func calculate_shapecast_offset()->Vector3:
	# up in the update function I set the shapecast's target position equal to offset.
	
	var collision_point = shape_cast.get_collision_point(0)
	# buffer radius is equal to the shapecast sphere shape radius
	var collision_normal = (shape_cast.get_collision_normal(0))*buffer_radius
	var new_point = collision_point+collision_normal
	return(new_point)
