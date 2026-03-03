extends Control

@onready var progress_bar_health: ProgressBar = $MarginContainer_Bars/VBoxContainer/ProgressBar_Health
@onready var progress_bar_stamina: ProgressBar = $MarginContainer_Bars/VBoxContainer/ProgressBar_Stamina


func _ready() -> void:
	SignalBus.connect("LIFE_CHANGE",update_life)
	SignalBus.connect("STAMINA_CHANGE",update_stamina)

func update_life():
	pass
	
func update_stamina(stamina_amt:float):
	progress_bar_stamina.value = stamina_amt
