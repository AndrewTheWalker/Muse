extends Node
class_name Animator


@onready var animator: AnimationPlayer = $"../SkeletonAnimator"

@onready var model : PlayerModel = $".."
@export var skeleton : Skeleton3D 

var current_animation 

func update_body_animations():
	set_animations()


func set_animations():
	play_animation(model.current_move.animation)


func play_animation(animation : String):
	animator.play(animation)


func set_speed_scale(speed : float):
	animator.speed_scale = speed


func reset_animation():
	animator.seek(0)
