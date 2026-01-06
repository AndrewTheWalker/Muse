extends Node
class_name PlayerModel

'''ADAPTED FROM CODE BY GAB OF THE FAIR FIGHT YOUTUBE CHANNEL'''

# this class is the state machine

@onready var player = $".."
@onready var skeleton = %GeneralSkeleton
@onready var animator = $SkeletonAnimator

var current_move : Move

@onready var moves = {
	"idle" : $States/Idle,
	"run" : $States/Run,
	"jump" : $States/Jump,
	"sprint" : $States/Sprint,
	"midair" : $States/Midair,
	"land" : $States/Land,
	"sprintjump" : $States/Sprint_Jump,
	"sprintland" : $States/Sprint_Land,
	
}

# my previous version of the state machine had the ready function check the SM's children and append
# them to a state array in the ready function. In this case, we define the dictionary ourselves.
func _ready():
	print(player)
	current_move = moves["idle"]
	for move in moves.values():
		move.player = player

# call the moves check_relevance function. If it returns okay, then proceed
func update(input : InputPackage, delta : float):
	var relevance = current_move.check_relevance(input)
	if relevance != "okay":
		switch_to(relevance)
	current_move.update(input, delta)
	# temporary little measure to make the run speed look faster
	if current_move is Sprint:
		animator.speed_scale = 1.5
	else:
		animator.speed_scale = 1.0

# calls the current move's exit function, switches to the new move, then calls the new move's enter function
func switch_to(state : String):
	current_move.on_exit_state()
	current_move = moves[state]
	current_move.on_enter_state()
	current_move.mark_enter_state()
	animator.play(current_move.animation)
