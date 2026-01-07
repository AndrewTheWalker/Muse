extends Move
class_name Jump


const VERTICAL_SPEED_ADDED = 3.5

# 1.33 is the total anim time for jump start
# 0.11 is the time when the character's feet should lift from the ground
const TRANSITION_TIMING = 0.33
const JUMP_TIMING = 0.11

var jumped : bool = false

func _ready():
	animation = "Jump_Start"

# check if this state's existence exceeds the transition timing, then return midair
func check_relevance(input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else:
		return "okay"

# after a very slight delay to sync with our animation, do the jump function
func update(input, delta):
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true
	player.move_and_slide()

func on_enter_state():
	print("entered regular jump")
