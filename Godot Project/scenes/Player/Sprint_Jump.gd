extends Move
class_name SprintJump

# Step 0: Not sure how this template was made? This script exists in a folder called Templates.
# In project settings (advanced) under Editor>Scripts, you may select a folder as the projects "template" folder.

# Step 1: redefine your class_name

# Step 2: redefine your overriden parameters 
func _ready():
	animation = "Jump"
	move_name = "dasdasdas"

# Step 3: navigate to Model and add a new state to moves dictionary
# Step 4: navigate to base Move and add this new state to priority dictionary


# Step 5: implement a check_relevance function to manage transitions, return action name or "okay"
func check_relevance(input : InputPackage):
	pass
# example
# input.actions.sort_custom(moves_priority_sort)
# if input.actions[0] == "run":
	# return "okay"
# return input.actions[0]

# Step 6: implement an update function
func update(input : InputPackage, delta : float):
	pass

# Step 7: use these bros if needed
func on_enter_state():
	pass

func on_exit_state():
	pass

# Step 8: delete annoying comments telling you what to do
