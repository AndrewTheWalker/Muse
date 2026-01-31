extends Move

@export var SPEED = 5.0
@export var VERTICAL_SPEED_ADDED : float = 4.0

const TRANSITION_TIMING = 0.33  
const JUMP_TIMING = 0.11

var jumped : bool = false


func default_lifecycle(_input : InputPackage):
	if works_longer_than(TRANSITION_TIMING):
		jumped = false
		return "midair"
	else: 
		return "okay"


func update(_input : InputPackage, _delta ):
	process_jump()
	player.move_and_slide()


func process_jump():
	if works_longer_than(JUMP_TIMING):
		if not jumped:
			#player.velocity = -(player.basis.z) * SPEED 
			player.velocity.y += VERTICAL_SPEED_ADDED
			jumped = true


func on_enter_state():
	player.velocity = player.velocity.normalized() * SPEED 
