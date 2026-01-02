extends Node
class_name InputGatherer

# capitalized strings refer to the input map
# lowercase strings refer to the contents of the inputpackage array

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()
	
	if Input.is_action_just_pressed("Jump"):
		new_input.actions.append("jump")
		
	if Input.is_action_just_pressed("DodgeSprint"):
		new_input.actions.append("DodgeSprint")
	
	if Input.is_action_just_pressed("Lock"):
		new_input.actions.append("lock")
	
	if Input.is_action_just_pressed("Shoot"):
		new_input.actions.append("shoot")
		
	if Input.is_action_just_pressed("Interact"):
		new_input.actions.append("interact")
		
		
	if new_input.actions.is_empty():
		new_input.actions.append("idle")
		
	return new_input
