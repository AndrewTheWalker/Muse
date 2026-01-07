extends CharacterBody3D

@export var use_debug_cam := false

@onready var input_gatherer = $Input as InputGatherer
@onready var model = $Model as PlayerModel
@onready var visuals = $Visuals as PlayerVisuals

@onready var local_camera: CameraManager = %LocalCamera



func _ready() -> void:
	if use_debug_cam == false:
		local_camera.camera.make_current()
	else:
		print("debug camera active")
	visuals.accept_skeleton(model.skeleton)

func _physics_process(delta):
	var input = input_gatherer.gather_input()
	model.update(input, delta)
	# because the inputs are a data package, they would keep piling up if we don't free them.
	input.queue_free()
