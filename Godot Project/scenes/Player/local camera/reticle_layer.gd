extends CanvasLayer

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var progress_bar_stamina: TextureProgressBar = $Sprite2D/Control/TextureProgressBar

@onready var local_camera: CameraModel = $".."
@onready var camera: Camera3D = $"../PlayerCamera"


func _ready() -> void:
	SignalBus.connect("STAMINA_CHANGE",update_stamina)
	progress_bar_stamina.visible=false

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Lock"):
		sprite_2d.play("lock")
		progress_bar_stamina.visible=true
	if event.is_action_released("Lock"):
		sprite_2d.play("unlock")
		progress_bar_stamina.visible=false

func update_stamina(stamina_amt:float):
	progress_bar_stamina.value = 100-stamina_amt
	
	if stamina_amt < 30:
		progress_bar_stamina.tint_progress = Color.CRIMSON
	else:
		progress_bar_stamina.tint_progress = Color.CORAL
