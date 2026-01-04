extends Node
class_name PlayerModel

'''ADAPTED FROM CODE BY GAB OF THE FAIR FIGHT YOUTUBE CHANNEL'''

# this class is the state machine

@onready var player = $".."
var current_move : Move

@onready var moves = {
	"idle" : $Idle,
	"run" : $Run,
	"jump" : $Jump
}

# my previous version of the state machine had the ready function check the SM's children and append
# them to a state array in the ready function. In this case, we define the dictionary ourselves.
func _ready():
	current_move = moves["idle"]
	for move in moves.values():
		move.player = player

# call the moves check_relevance function. If it returns okay, then proceed
func update(input : InputPackage, delta : float):
	var relevance = current_move.check_relevance(input)
	if relevance != "okay":
		switch_to(relevance)
	current_move.update(input, delta)

# calls the current move's exit function, switches to the new move, then calls the new move's enter function
func switch_to(state : String):
	current_move.on_exit_state()
	current_move = moves[state]
	current_move.on_enter_state()
