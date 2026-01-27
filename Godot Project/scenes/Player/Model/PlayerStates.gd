extends Node
class_name PlayerStates


@export var player : CharacterBody3D
#@export var base_animator : AnimationPlayer
#@export var animator : AnimationPlayer
@export var animator : SplitBodyAnimator
@export var skeleton : Skeleton3D
@export var resources : PlayerResources
@export var combat : Combat
@export var area_awareness : AreaAwareness
@export var moves_data_repo : MovesDataRepository
#@export var legs : Legs
#@export var left_wrist : BoneAttachment3D

var moves : Dictionary # { string : Move }, where string is Move heirs name


func accept_moves():
	for child in get_children():
		if child is Move:
			moves[child.move_name] = child
			child.player = player
			child.animator = animator
			child.skeleton = skeleton
#			child.base_animator = base_animator
			child.resources = resources
			child.combat = combat
			child.moves_data_repo = moves_data_repo
			child.container = self
			child.DURATION = moves_data_repo.get_duration(child.backend_animation)
			child.area_awareness = area_awareness
			#child.legs = legs
			#child.left_wrist = left_wrist
			child.assign_combos()


# moves priority sort for standard actions, not combat ones. 

func moves_priority_sort(a : String, b : String):
	if moves[a].priority > moves[b].priority:
		return true
	else:
		return false


func get_move_by_name(move_name : String) -> Move:
	return moves[move_name]
