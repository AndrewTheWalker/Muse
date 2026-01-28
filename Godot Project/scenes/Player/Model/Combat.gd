extends Node
class_name Combat

#I am including this script for the moment because it may be useful.
# I am really starting to think I don't need this class at all, though.

@onready var model = $".." as PlayerModel


# so I probably don't need this bit here. I don't have light and heavy attacks. 

static var inputs_priority : Dictionary = {
	"light_attack_pressed" : 1,
	"heavy_attack_pressed" : 2
}


# this will be called to run the other functions in this script.

func contextualize(new_input : InputPackage) -> InputPackage:
	translate_inputs(new_input)
	filter_with_resources(new_input)
	return new_input
	
# this turns the combat combo action into a string. I will almost certainly never need this.
	
func translate_inputs(input : InputPackage):
	if not input.combat_actions.is_empty():
		input.combat_actions.sort_custom(combat_action_priority_sort)
		var best_input_action : String = input.combat_actions[0]
		var translated_into_move_name : String = model.active_weapon.basic_attacks[best_input_action]
		input.actions.append(translated_into_move_name)
		
# this is the one I'm more interested in, but again, it probably doesn't need its own script.
# I'll figure this out when I write out the resources script.
		
func filter_with_resources(input: InputPackage):
	if model.resources.statuses.has("fatigue"):
		input.actions.erase("sprint")
		
		
# simple sort function.
		
static func combat_action_priority_sort(a,b):
	if inputs_priority[a] > inputs_priority[b]:
		return true
	else:
		return false
