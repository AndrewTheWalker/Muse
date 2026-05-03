extends CharacterBody3D
class_name PlayerKor

@export var use_debug_cam := false
@export var use_debug_meshes := false


@onready var input_gatherer = $Input as InputGatherer
@onready var model = $Model as PlayerModel
@onready var visuals = $Visuals as PlayerVisuals
@onready var audio_manager: Node = $AudioManager
@onready var sparks: GPUParticles3D = $Model/Sparks
@onready var invinc_timer: Timer = $InvincTimer
@onready var electric_timer: Timer = $ElectricTimer


@onready var local_camera: CameraModel = %LocalCamera
@onready var camera: Camera3D = %LocalCamera/PlayerCamera

var is_alive: bool = true
var is_electrified : bool = false

func _ready() -> void:
	if use_debug_cam == false:
		local_camera.camera.make_current()
	else:
		print("debug camera active")
	if use_debug_meshes == false:
		get_all_children_recursive(self)
	visuals.accept_model(model)
	visuals.accept_skeleton(model.skeleton)
	SignalBus.connect("ELECTRIC_ENTERED",electric_on)
	SignalBus.connect("ELECTRIC_EXITED",electric_off)
	## This is a bit of a hacky solution. In the future, the game needs to have a discreet cutscene state.
	SignalBus.connect("CUTSCENE_ACTIVATED",cutscene)

func _physics_process(delta):
	var input = input_gatherer.gather_input()
	var reticle = local_camera.find_reticle_point()
	model.update(input, delta)
	
	# because the inputs are a data package, they would keep piling up if we don't free them.
	input.queue_free()

# this function is just used to ease debugging.
func get_all_children_recursive(node):
	var nodes = []
	for child in node.get_children():
		nodes.append(child)
			# Recursively call the function for grandchildren and beyond
		nodes.append_array(get_all_children_recursive(child))
		for i in nodes:
			if i.is_in_group("debugtool"):
				i.hide()
	return nodes

func cutscene():
	print("cutscene activated")
	process_mode = Node.PROCESS_MODE_DISABLED
	
func receive_hit():
	# tell model to call resources.
	model.take_damage()

func play_hit_flash():
	var material = visuals.mesh.get_active_material(0)
	material.set_shader_parameter("flash_modifier",1.0)
	await get_tree().create_timer(0.1).timeout
	material.set_shader_parameter("flash_modifier",0.0)

func turn_off_emissive():
	var material = visuals.mesh.get_active_material(0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(material,"shader_parameter/emission_energy", 0.0,2.0)
	await tween.finished
	material.set_shader_parameter("emission_energy",-1.0)

func send_sound(sound_name : String):
	audio_manager.play_sound(sound_name)
	
func stop_sound(sound_name : String):
	audio_manager.stop_playing(sound_name)


func rotate_to(target_dir:Vector3):
	var current_dir = global_rotation
	var angle = current_dir.signed_angle_to(target_dir,Vector3.UP)
	global_rotation = global_rotation.rotated(Vector3.UP,angle)


func electric_on():
	is_electrified = true
	sparks.emitting = true
	receive_hit()
	electric_timer.start()

func electric_off():
	is_electrified = false
	sparks.emitting = false

func _on_electric_timer_timeout() -> void:
	if is_electrified:
		receive_hit()
		electric_timer.start()
	else:
		pass
