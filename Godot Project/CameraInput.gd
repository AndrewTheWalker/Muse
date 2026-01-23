extends Node
class_name CameraInputGatherer


func gather_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	if Input.is_action_just_pressed("Lock"):
		new_input.actions.append("lock")
	
	new_input.r_input_direction = Input.get_vector("Rstick_left","Rstick_right","Rstick_down","Rstick_up")
	if new_input.r_input_direction != Vector2.ZERO:
		new_input.actions.append("aim")
	
	return new_input
