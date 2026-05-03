extends Control
class_name AimAssistDebugDraw

@onready var local_camera: CameraModel = $"../.."
@onready var cone_finder: ConeFinder = $".."
@onready var player_camera: Camera3D = $"../../PlayerCamera"

@onready var viewport_size = get_viewport_rect().size

var radius : float
var intensity = 1.0
var center : Vector2

func _process(delta: float) -> void:
	center = local_camera.get_unprojected_position()
	queue_redraw()

func _draw() -> void:
	var circle_color = Color.WHITE.lerp(Color.RED,intensity)
	var fov_rad = deg_to_rad(player_camera.fov)
	var target_rad = deg_to_rad(cone_finder.angle_degrees)
	radius = (tan(target_rad/2.0) / tan(fov_rad/2.0) * (viewport_size.y))
	draw_arc(center,radius,0,TAU,64,circle_color,3.0,false)
	
