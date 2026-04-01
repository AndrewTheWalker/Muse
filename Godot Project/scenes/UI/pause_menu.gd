extends Control


@onready var button_resume: Button = $MarginContainer/VBoxContainer/ButtonResume
@onready var button_controls: Button = $MarginContainer/VBoxContainer/ButtonControls
@onready var button_quit: Button = $MarginContainer/VBoxContainer/ButtonQuit
@onready var check_box_h: CheckBox = $MarginContainer/VBoxContainer/CheckBoxH
@onready var check_box_v: CheckBox = $MarginContainer/VBoxContainer/CheckBoxV
@onready var h_slider_h_sens: HSlider = $MarginContainer/VBoxContainer/HSliderHSens
@onready var h_slider_v_sens: HSlider = $MarginContainer/VBoxContainer/HSliderVSens
@onready var sfx_menu_1: AudioStreamPlayer = $Menu1
@onready var sfx_menu_3: AudioStreamPlayer = $Menu3
@onready var sfx_menu_2: AudioStreamPlayer = $Menu2

@onready var controls_ui_scene = load("res://scenes/UI/view_controls_gui.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# note to self
# it seems a little backwards that notification_paused calls the hide function and vice versa, but that is
# because for this node, whose process mode is WHEN_PAUSED, paused means unpaused for this particular node.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			_hide()
		NOTIFICATION_UNPAUSED:
			_show()


func _hide():
	hide()

func _show():
	show()
	sfx_menu_2.play()
	button_resume.grab_focus()


func _input(event: InputEvent) -> void:
	var current = get_viewport().gui_get_focus_owner()
	if !current:
		return

	if current is HSlider:
		if Input.is_action_just_pressed("ui_left"):
			current.value -= 0.5
		if Input.is_action_just_pressed("ui_right"):
			current.value += 0.4
			

	if Input.is_action_just_pressed("Pause"):
		print("pause button in pause menu pressed")
		Gamestate.toggle_pause()
		accept_event()


# Note to Self.
# In proper practice, I really ought to have a dedicated user preference autoload or something along those lines. 


func _on_check_box_h_toggled(toggled_on: bool) -> void:
	sfx_menu_3.play()
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("h_up")


func _on_check_box_v_toggled(toggled_on: bool) -> void:
	sfx_menu_3.play()
	if toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_down")
	if ! toggled_on:
		SignalBus.INVERT_SIGNAL.emit("v_up")


func _on_h_slider_h_sens_value_changed(value: float) -> void:
	sfx_menu_3.play()
	SignalBus.ADJUST_HSENS.emit(value)


func _on_h_slider_v_sens_value_changed(value: float) -> void:
	sfx_menu_3.play()
	SignalBus.ADJUST_VSENS.emit(value)


func _on_button_resume_pressed() -> void:
	print("resume button pressed")
	Gamestate.toggle_pause()

func _on_button_controls_pressed() -> void:
	sfx_menu_3.play()
	var control_scene = controls_ui_scene.instantiate()
	add_child(control_scene)
	disable_buttons()
	print("controls button pressed")

func disable_buttons():
	button_resume.set_focus_mode(Control.FOCUS_NONE)
	button_controls.set_focus_mode(Control.FOCUS_NONE)
	button_quit.set_focus_mode(Control.FOCUS_NONE)
	check_box_h.set_focus_mode(Control.FOCUS_NONE)
	check_box_v.set_focus_mode(Control.FOCUS_NONE)
	h_slider_h_sens.set_focus_mode(Control.FOCUS_NONE)
	h_slider_v_sens.set_focus_mode(Control.FOCUS_NONE)
			
func enable_buttons():
	button_resume.set_focus_mode(Control.FOCUS_ALL)
	button_controls.set_focus_mode(Control.FOCUS_ALL)
	button_quit.set_focus_mode(Control.FOCUS_ALL)
	check_box_h.set_focus_mode(Control.FOCUS_ALL)
	check_box_v.set_focus_mode(Control.FOCUS_ALL)
	h_slider_h_sens.set_focus_mode(Control.FOCUS_ALL)
	h_slider_v_sens.set_focus_mode(Control.FOCUS_ALL)

func _on_button_quit_pressed() -> void:
	set_process_input(false)
	sfx_menu_1.play()
	await get_tree().create_timer(1.1).timeout
	get_tree().paused = !get_tree().paused
	Gamestate.game_controller.change_3d_scene("res://scenes/UI/main_menu_3d.tscn")
	Gamestate.game_controller.change_gui_scene("res://scenes/UI/main_menu_gui.tscn")
	
