extends Control

@onready var progress_bar_health: TextureProgressBar = $MarginContainer_Bars/VBoxContainer/ProgressBar_Health
@onready var progress_bar_stamina: TextureProgressBar = $MarginContainer_Bars/VBoxContainer/ProgressBar_Stamina

var default_stamina_colour : Color

func _ready() -> void:
	SignalBus.connect("LIFE_CHANGE",update_life)
	SignalBus.connect("STAMINA_CHANGE",update_stamina)

func update_life(health_amt:float):
	progress_bar_health.value = health_amt
	
func update_stamina(stamina_amt:float):
	progress_bar_stamina.value = stamina_amt
	if stamina_amt < 30:
		progress_bar_stamina.tint_under = Color.CRIMSON
	else:
		progress_bar_stamina.tint_under = Color.CORAL
