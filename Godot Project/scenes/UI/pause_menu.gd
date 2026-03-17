extends Control


@onready var button_resume: Button = $MarginContainer/VBoxContainer/ButtonResume
@onready var check_box_h: CheckBox = $MarginContainer/VBoxContainer/CheckBoxH
@onready var check_box_v: CheckBox = $MarginContainer/VBoxContainer/CheckBoxV
@onready var h_slider_h_sens: HSlider = $MarginContainer/VBoxContainer/HSliderHSens
@onready var h_slider_v_sens: HSlider = $MarginContainer/VBoxContainer/HSliderVSens


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_resume.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _hide():
	hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	var current = get_viewport().gui_get_focus_owner()
	if !current:
		return

	if current is HSlider:
		if event.is_action_released("ui_left"):
			current.value -= 1
		if event.is_action_released("ui_right"):
			current.value += 1



# Note to Self.
# In proper practice, I really ought to have a dedicated user preference autoload or something
# along those lines. 


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


func _on_h_slider_h_sens_value_changed(value: float) -> void:
	print("h_sens slider value change to ",value)


func _on_h_slider_v_sens_value_changed(value: float) -> void:
	print("v_sens slider value change to ",value)


func _on_button_resume_pressed() -> void:
	print("resume button pressed")
