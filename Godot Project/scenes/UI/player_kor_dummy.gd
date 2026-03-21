extends CharacterBody3D

@onready var skeleton_animator: AnimationPlayer = $SkeletonAnimator
@onready var node_animator: AnimationPlayer = $NodeAnimator

func play_idle():
	skeleton_animator.play("Idle")
	
func play_walk():
	skeleton_animator.play("Walk")
	node_animator.play("move_fwd")
