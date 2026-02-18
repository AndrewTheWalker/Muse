extends Node


# this little thing seems to just be a dictionary, I guess I'll figure it out as I go forward with this.
# it seems like it's important for the forced moves.

func get_default_reactions_dictionary() -> Dictionary:
	return {
		"death" : $Death,
		"overheat" : $Overheat
	}
