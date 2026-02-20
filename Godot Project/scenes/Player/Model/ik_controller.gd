extends Node
class_name IKController

@onready var timer: Timer = $"../Timer"

@onready var spine_ccdik_3d: CCDIK3D = $"../GeneralSkeleton/SpineCCDIK3D"
@onready var l_arm_ik: TwoBoneIK3D = $"../GeneralSkeleton/L_Arm_IK"
@onready var r_arm_ik: TwoBoneIK3D = $"../GeneralSkeleton/R_Arm_IK"

var influence : float = 0.0
var is_shooting : bool = false

func _ready() -> void:
	influence = 0.0


	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Shoot"):
		is_shooting = true
		influence = 1.0
		spine_ccdik_3d.influence = influence
		l_arm_ik.influence = influence
		r_arm_ik.influence = influence
	if event.is_action_released("Shoot"):
		timer.start()
		await timer.timeout
		is_shooting = false
		influence = 0.0
		spine_ccdik_3d.influence = influence
		l_arm_ik.influence = influence
		r_arm_ik.influence = influence
		
		
		
