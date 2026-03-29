extends CanvasLayer

@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var local_camera: CameraModel = $".."
@onready var camera: Camera3D = $"../PlayerCamera"


func _process(delta: float) -> void:
	sprite_2d.position = local_camera.get_unprojected_position()
	if ! camera.current:
		sprite_2d.visible=false
	else:
		sprite_2d.visible=true

func find_unprojected_position():
	var position = local_camera.get_unprojected_position()
	print("canvaslayer ", position)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			hide()
		NOTIFICATION_UNPAUSED:
			show()
