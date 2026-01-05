extends Node
class_name InputGatherer

# capitalized strings refer to the input map
# lowercase strings refer to the contents of the inputpackage array

# this class takes all the inputs that are happening at any given frame, and creates an InputPackage.
# the input package class will then create an array of those inputs to send to whichever component cares about them.

func gather_input() -> InputPackage:
	var new_input = InputPackage.new()
		
	if new_input.actions.is_empty():
		new_input.actions.append("idle")
	
	if Input.is_action_just_pressed("Jump"):
		if new_input.actions.has("sprint"):
			new_input.actions.append("sprint_jump")
		else:
			new_input.actions.append("jump")
		
	'''UNCOMMENT WHEN READY'''
	# if Input.is_action_just_pressed("DodgeSprint"):
		# new_input.actions.append("DodgeSprint")
	
	'''UNCOMMENT WHEN READY'''
	# if Input.is_action_just_pressed("Shoot"):
		# new_input.actions.append("shoot")
		
	'''UNCOMMENT WHEN READY'''
	# if Input.is_action_just_pressed("Interact"):
		# new_input.actions.append("interact")
		
	new_input.l_input_direction = Input.get_vector("Lstick_left","Lstick_right","Lstick_down","Lstick_up")
	if new_input.l_input_direction != Vector2.ZERO:
		new_input.actions.append("run")
		if Input.is_action_pressed("DodgeSprint"):
			new_input.actions.append("sprint")
	
	'''CAMERA SPECIFIC ACTIONS, UNCOMMENT WHEN READY'''
	# these inputs don't control the player, we'll need to give them to the camera controller
	# when we implement features like target switching
	# however, the camera controller doesn't exist yet.
	
	# new_input.r_input_direction = Input.get_vector("Rstick_left","Rstick_right","Rstick_down","Rstick_up")
	# if new_input.r_input_direction != Vector2.ZERO:
		# new_input.actions.append("aim")
		
	# if Input.is_action_just_pressed("Lock"):
		# new_input.actions.append("lock")
		
	return new_input
