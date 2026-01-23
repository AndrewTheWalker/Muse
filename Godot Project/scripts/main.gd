extends Node

func _ready():
	pass
	#Engine.time_scale = 0.1
	


func _on_checkbox_h_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_up")

func _on_checkbox_v_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_up")
