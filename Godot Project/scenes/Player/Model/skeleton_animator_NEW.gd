extends AnimationPlayer

func _ready():
	configure_blending_times()

func configure_blending_times():
	print("configuring blend times")
	set_blend_time("Jog", "Idle", 0.75)
	set_blend_time("Idle", "Jog", 0.75)
	set_blend_time("Jog", "Jump_Idle_Start", 0.25)
	set_blend_time("Jump_Idle_Land", "Jog", 0.25)
	set_blend_time("Jump_Idle_Start", "Jump_Midair", 0.5)
	set_blend_time("Jump_Midair", "Jump_Idle_Land", 0.5)
	set_blend_time("Jump_Idle_Land", "Idle", 0.5)
	#set_blend_time("Jump_Sprint_Start", "Jump_Midair", 0.3)
	#set_blend_time("Jump_Sprint_Land", "Sprint", 0.3)
