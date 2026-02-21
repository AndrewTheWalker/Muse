extends Node
class_name IKController

@onready var timer: Timer = $"../Timer"
@onready var model : PlayerModel = $".."

@onready var head_look_at: LookAtModifier3D = $"../GeneralSkeleton/HeadLookAt"
@onready var spine_ccdik_3d: CCDIK3D = $"../GeneralSkeleton/SpineCCDIK3D"
@onready var l_arm_ik: TwoBoneIK3D = $"../GeneralSkeleton/L_Arm_IK"
@onready var r_arm_ik: TwoBoneIK3D = $"../GeneralSkeleton/R_Arm_IK"
@onready var head_copy_rotation: CopyTransformModifier3D = $"../GeneralSkeleton/HeadCopyRotation"

var influence : float = 0.0

var tween: Tween

func _ready() -> void:
	influence = 0.0


func _process(delta: float) -> void:
		head_look_at.influence = influence
		spine_ccdik_3d.influence = influence
		l_arm_ik.influence = influence
		r_arm_ik.influence = influence
		head_copy_rotation.influence = influence


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Roll"):
		if tween and tween.is_valid():
			tween.stop()
		influence = 0.0


func process_ik(command:String):
	if command == "shoot":
		if tween and tween.is_valid():
			tween.kill()
		model.is_shooting = true
		tween_influence(1.0,0.02)
		
	if command == "release":
		timer.start()
		await timer.timeout
		model.is_shooting = false
		tween_influence(0.0,0.75)
		SignalBus.TARGET_DROPPED.emit()

func tween_influence(value:float,time:float):
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"influence",value,time)
