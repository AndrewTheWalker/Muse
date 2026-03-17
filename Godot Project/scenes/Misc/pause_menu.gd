extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_box_h_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_up")

func _on_check_box_v_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_up")
